# 自动化脚本配置lnmp环境

由于大学期间，折腾服务器的配置环境遇到不少巨坑，所以一直想弄一个自动化脚本。

功能：
1. 安装 `./install.sh`   sync,nginx,php,redis,mysql 
2. 卸载 `./uninstall.sh`  nginx,php,redis,mysql

# 环境配置

目前适用
ubnutu 16.04 

# 软件说明

1. 相关软件版本
 - nginx (1.12)
 - php (5.6.30 7.1.6)
 - redis (4.0.0)
 - mysql (5.6 5.7)
2. 软件安装包存放在云盘，需要先下载到`./src/`的目录中


# 安装说明


1.  /usr/local/xxx 安装目录
2.  /data/xxx 数据目录
3.  /usr/local/xxx/etc /usr/local/xxx/conf/ 配置目录
4.  /data/logs/xxx 日志

> xxx指的是安装软件的名字，具体有（nginx,redis,php,mysql）

# 具体操作

## 拉取脚本

```shell
apt-get update # 更新源
apt-get installl -y git # 安装git
# 拉取代码，建议脚本放在`/data/lnmp`
mkdir -p /data
cd /data
git clone https://github.com/kamly/automated-operation.git
```

## 上传资源

软件安装包存放在[云盘]()。

先下载到本地，然后上传到服务器的`./src/`目录中

## ./install.sh

执行安装命令 `./install.sh`

1. 是否安装 sync_time 时间同步



2. 是否安装 nginx nginx服务器





3. 是否安装







## ./uninstall.sh




