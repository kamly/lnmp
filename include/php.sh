#!/bin/bash          


# 安装 php 依赖
pre_install_php(){
    if [[ `grep www /etc/passwd | wc -l` == 0 ]];then
      useradd -M -s /sbin/nologin -g $php_group $php_user # 添加php用户
    fi

    # install_curl       
    install_curl(){      
        pushd ${src_dir}
        tar xjf {$curl_version_tar} && cd {$curl_version} 
        ./configure --prefix=/usr/local/curl
        make && make install      
        popd
        rm -rf $src_dir/$curl_version
    }
    install_curl  # 安装curl  

    if [ $os == "centos" ];then
        yum install -y gcc gcc-c++ libxml2 libxml2-devel libjpeg-devel libpng-devel freetype-devel openssl-devel libcurl-devel libmcrypt libmcrypt-devel libicu-devel libxslt-devel   
    elif [ $os == "ubuntu" ];then
        apt-get update   
        apt-get install  libxml2  libxml2-dev -y
        apt-get install  openssl libssl-dev -y
        apt-get install  curl libcurl4-gnutls-dev -y
        apt-get install libjpeg-dev libpng12-dev   libxpm-dev libfreetype6-dev  libmcrypt-dev  libmysql++-dev  libxslt1-dev  libicu-dev  -y
        ln -sf /usr/lib/${sys_bit}-linux-gnu/libssl.so  /usr/lib # 设置软链
    fi
}
pre_install_php

   

# 安装 libmcrypt
install_libmcrypt(){
    pushd $src_dir
    tar xzf ${libmcrypt_tar} && cd $libmcrypt
    ./configure
    make && make install
    popd
    rm -rf $src_dir/$libmcrypt
}
install_libmcrypt


# 安装 PHP
install_php(){
 
    echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig # 安装了一个新的动态链接库时，就需要手工运行这个命令。

    pushd $src_dir # 跳转到指定目录，输出堆栈

    php_install_dir_use="${php_dir}/${php_version[${php_version_select}]}" # php 安装目录

    tar xjvf ${php_bz[${php_version_select}]} && cd ${php_version[${php_version_select}]} # 解压

    # 设置 config 配置
    config_php(){

        # fix curl missing for debian
        if [[ `grep -i debian /etc/issue | wc -l` == 1 ]];then
            ln -fs /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl
            apt-get install -y libjpeg-dev libpng-dev  libfreetype6-dev make gcc
        elif [[ $os == "ubuntu" ]];then
            ln -fs /usr/include/${sysbit}-linux-gnu/curl /usr/include/
        fi

        ./configure --prefix=${php_install_dir_use} --with-config-file-path=${php_install_dir_use}/etc \
        --with-config-file-scan-dir=${php_install_dir_use}/etc/php.d \
        --with-fpm-user=www --with-fpm-group=www --enable-fpm --enable-opcache --disable-fileinfo \
        --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
        --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
        --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
        --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex \
        --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
        --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
        --with-gettext --enable-zip --enable-soap --disable-debug
        make ZEND_EXTRA_LIBS='-liconv'
        make
        ln -fs /usr/local/lib/libiconv.so.2 /usr/lib64/ 
        ln -fs /usr/local/lib/libiconv.so.2 /usr/lib/ 
        make install

        if [[ -e ${php_install_dir_use}/bin/phpize ]];then
            echo -e "php install successful!"
        else
            echo -e "${RED}php install failed, Please contact author.${WHITE}"
            exit || kill -9 $$
        fi

        cp -f php.ini-production ${php_install_dir_use}/etc/php.ini && cp -f sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && chmod +x /etc/init.d/php-fpm
    }
    config_php 

    # 添加php服务
    add_php_boot(){
        if [[ $os == "centos" ]];then
            chkconfig  php-fpm on  && chkconfig save
        elif  [[ $os == "ubuntu" ]];then
            update-rc.d php-fpm defaults
        fi
        ln -fs ${php_install_dir_use}/bin/php /usr/bin/php
    }
    add_php_boot # 添加php服务

    popd

    # 复制php-fpm
    copy_php_fpm(){

        cp -f ./conf/php-fpm.conf ${php_install_dir_use}/etc #  复制脚本文件

        # 重启服务
        service php-fpm restart
        
        # 删除文件
        rm -rf $src_dir/${php_version[$php_version_select]}
    }
    copy_php_fpm # 复制php-fpm

    # 日志
    [ ! -d /data/logs/php ] && mkdir -p /data/logs/php
}
install_php  
