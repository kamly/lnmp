#!/bin/bash

# ------------------------
#  卸载规则
#  1. 确认该目录是否存在
#  2. 停止运行
#  3. 删除开机自启服务
#  4. 删除服务脚本
#  5. 删除/bin/ 软连
#  6. 删除/data/xxx 数据目录
#  7. 删除/data/logs/xxx 日志目录
#  8. 删除/usr/local/xxx 软件目录
# ------------------------

clear

. ../include/common.sh # 引入常量文件
. ../include/public.sh # 引入公用函数
. ../include/sysinfo.sh # 输出系统信息

# 卸载 Nginx
uninstall_nginx(){
	read -p "Please Choose Uninstall nginx or Not! ( y,Y/n,N )" uninstall_nginx
	case ${uninstall_nginx} in
	y|Y)
		if [ -d ${nginx_install_dir} ];then # 确认该目录是否存在
			
			service nginx stop  && sleep 3  # 停止运行
			# ps -eaf | grep nginx | grep master | awk  '{print $2}' | xargs kill -9
			
			# 删除开机自启服务
			if [ ${os} == "centos" ];then
				chkconfig nginx off && chkconfig save
			elif [ ${os} == "ubuntu" ];then
				update-rc.d nginx remove	
			fi

			rm -rf /etc/init.d/nginx  # 删除服务脚本

			# 删除 /bin/ /data/xxx data/logs/xxx /usr/local/xxx
			rm -rf  /usr/bin/nginx  ${nginx_root_dir} ${nginx_logs} ${nginx_install_dir} 
			
			echo  "Uninstall nginx successful!" 
		else
			echo
			echo "No nginx installed in your system!!"
		fi
	;;
	n|N)
		echo  "You select not uninstall nginx!"
	;;
	*)
		echo  "Input error to uninstall nginx!"
	;;
	esac
}
uninstall_nginx



	
# 卸载 Php
uninstall_php(){

	read -p "Please Choose Uninstall php or Not! ( y,Y/n,N )" uninstall_php
	case ${uninstall_php} in
	y|Y)
		# 选择卸载的版本
		while :;do 
			echo -e "Please choose PHP version uninstall:
			${RED} 1)${WHITE} php-5.6.30;
			${RED} 2)${WHITE} php-7.1.6;"
			read -p "Your select:" php_version_select
			if [[ ! ${php_version_select} =~ ^[1,2]$ ]];then
				echo -e "${RED} Please input 1/2 "
			else
				break
			fi  
		done

    	if [ -d ${php_install_dir}/${php_version[${php_version_select}]} ];then # 确认该目录是否存在
     		
			service php-fpm stop && sleep 3  # 方法1 停止运行
			# ps -ef | grep php-fpm | grep -v grep | awk  '{print $2}' | xargs kill -9 # 方法2 停止运行
			
			# 删除开机自启服务
			if [ ${os} == "centos" ];then
				chkconfig php-fpm off && chkconfig save
			elif [ ${os} == "ubuntu" ];then
				update-rc.d php-fpm remove
			fi        

			rm -rf  /etc/init.d/php-fpm # 删除服务脚本

			# 删除 /bin/ /data/logs/xxx /usr/local/xxx
			rm -rf  /usr/bin/php ${php_logs} $php_install_dir/${php_version[${php_version_select}]} 
			
			echo  "Uninstall php successful!"
    	else
     	 echo "No php installed in your system!!"
    	fi 
	;;
	n|N)
			echo
			echo "You select not uninstall php!"
	;;
	*)
			echo
			echo  "Input error to uninstall php! "
	;;
	esac
}
uninstall_php




# 卸载 Redis
uninstall_redis(){

	read -p "Please Choose Uninstall redis or Not! ( y,Y/n,N )" uninstall_redis
	case ${uninstall_redis} in
	y|Y)
		if [ -d ${redis_install_dir} ];then # 确认该目录是否存在
			service redis stop && sleep 3  # 停止运行
			# ps aux | grep redis | grep -v grep | awk '{ print $2 }' | xargs kill -9 
			
			# 删除开机自启服务
			if [ ${os} == "ubuntu" ];then
				update-rc.d -f redis remove
			fi

			rm -rf  /etc/init.d/redis # 删除服务脚本

			# 删除 /bin/ /data/xxx data/logs/xxx /usr/local/xxx
			rm -rf  /usr/local/bin/redis-server /usr/local/bin/redis-cli  ${redis_data} ${redis_logs} $redis_install_dir 

			echo "Uninstall redis successful!"
		else
			echo "No redis installed in your system!"
		fi
	;;
	n|N)
		echo "You select not uninstall redis!"
	;;
	*)
		echo  "Input error to uninstall redis! "
	;;
	esac
}
uninstall_redis





# 卸载 mysql
uninstall_mysql(){

	read -p "Please Choose Uninstall mysql or Not! ( y,Y/n,N )" uninstall_mysql
	case ${uninstall_mysql} in
	y|Y)
		if [ -d ${mysql_install_dir} ];then  # 确认该目录是否存在
		
			service mysqld stop && sleep 3  # 停止运行
			# ps aux | grep mysql | grep -v grep | awk '{ print $2 }' | xargs kill -9 
			
			# 删除开机自启服务
			if [ ${os} == "ubuntu" ];then
				update-rc.d -f mysqld remove
			fi

			rm -rf /etc/init.d/mysqld # 删除服务脚本

			# 删除 /data/xxx data/logs/xxx /usr/local/xxx
			rm -rf ${mysql_data} ${mysql_log} ${mysql_install_dir}

			# 删除命令
			sed -i '/mysql\/bin/'d /etc/profile
			echo "export PATH=~/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin" >> /etc/profile
			source /etc/profile

			# 删除 mysql.sock
			rm -rf /var/lib/mysql

			# 使用ldconfig命令将/usr/local/mysql加入到默认库
			rm -rf /etc/ld.so.conf.d/mysql.conf
			ldconfig 
			
			echo "Uninstall mysql successful!"
		else
			echo -e "No Mysql Server installed in your system!!"
		fi
	;;
	n|N)
		echo  "You select not uninstall Mysql!"
	;;
	*)
		echo  "Input error to uninstall Mysql!!! "
	;;
	esac
}
uninstall_mysql




# 卸载 elasticsearch
uninstall_elasticsearch(){

	read -p "Please Choose Uninstall elasticsearch or Not! ( y,Y/n,N )" uninstall_elasticsearch
	case ${uninstall_elasticsearch} in
	y|Y)
		if [ -d ${elasticsearch_install_dir} ];then  # 确认该目录是否存在
		
			ps aux | grep elasticsearch | grep -v grep | awk '{ print $2 }' | xargs kill -9 

			# 删除 /data/xxx data/logs/xxx /usr/local/xxx
			rm -rf ${elasticsearch_data} ${elasticsearch_log} ${elasticsearch_install_dir}
			
			echo "Uninstall elasticsearch successful!"
		else
			echo -e "No elasticsearch Server installed in your system!!"
		fi
	;;
	n|N)
		echo  "You select not uninstall elasticsearch!"
	;;
	*)
		echo  "Input error to uninstall elasticsearch!!! "
	;;
	esac
}
uninstall_elasticsearch


# 卸载 kibana
uninstall_kibana(){

	read -p "Please Choose Uninstall kibana or Not! ( y,Y/n,N )" uninstall_kibana
	case ${uninstall_kibana} in
	y|Y)
		if [ -d ${kibana_install_dir} ];then  # 确认该目录是否存在
		
			ps aux | grep kibana | grep -v grep | awk '{ print $2 }' | xargs kill -9 

			# 删除 data/logs/xxx /usr/local/xxx
			rm -rf ${kibana_log} ${kibana_install_dir}
			
			echo "Uninstall kibana successful!"
		else
			echo -e "No kibana Server installed in your system!!"
		fi
	;;
	n|N)
		echo  "You select not uninstall kibana!"
	;;
	*)
		echo  "Input error to uninstall kibana!!! "
	;;
	esac
}
uninstall_kibana



# 卸载 filebeat
uninstall_filebeat(){

	read -p "Please Choose Uninstall filebeat or Not! ( y,Y/n,N )" uninstall_filebeat
	case ${uninstall_filebeat} in
	y|Y)
		if [ -d $filebeat_install_dir ];then  # 确认该目录是否存在
		
			ps aux | grep filebeat | grep -v grep | awk '{ print $2 }' | xargs kill -9 

			# 删除 data/logs/xxx /usr/local/xxx
			rm -rf ${filebeat_log} ${filebeat_install_dir} 
			
			echo "Uninstall filebeat successful!"
		else
			echo -e "No filebeat Server installed in your system!!"
		fi
	;;
	n|N)
		echo  "You select not uninstall filebeat!"
	;;
	*)
		echo  "Input error to uninstall filebeat!!! "
	;;
	esac
}
uninstall_filebeat


# 卸载 logstash
uninstall_logstash(){

	echo -e "$YELLOW"
	read -p "Please Choose Uninstall logstash or Not! ( y,Y/n,N )" uninstall_logstash
	case ${uninstall_logstash} in
	y|Y)
		if [ -d ${logstash_install_dir} ];then  # 确认该目录是否存在
		
			ps aux | grep logstash | grep -v grep | awk '{ print $2 }' | xargs kill -9 

			# 删除 data/logs/xxx /usr/local/xxx
			rm -rf ${logstash_log} ${logstash_install_dir}
			
			echo "Uninstall logstash successful!"
		else
			echo -e "No logstash Server installed in your system!!"
		fi
	;;
	n|N)
		echo  "You select not uninstall logstash!"
	;;
	*)
		echo  "Input error to uninstall logstash!!! "
	;;
	esac
}
uninstall_logstash


