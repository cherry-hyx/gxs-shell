#!/bin/bash
#created by lihuibin
#date 2014-01-15
#deploy web app to production install script
build_number=$1
build_id=$2
db_version="max_version"
myweb_path=/webdir/myweb/myweb.$build_number.$build_id
#项目配置文件
config_path=$myweb_path/config.php
ln -s $myweb_path/config/config.php  $config_path
#crontab.txt
ln -s   $myweb_path/config/crontab.txt  /etc/cron.d/myweb
#初始化数据库，如果数据库不存在则自动创建
/usr/bin/php $myweb_path/mysqlMigrations/migrate.php init
if [ $? -ne 0 ];then
  echo "db version table init:"$?
  exit 1
fi
#列出线上数据库版本
/usr/bin/php $myweb_path/mysqlMigrations/migrate.php list
if [ $? -ne 0 ];then
  echo "db version list:"$?
  exit 1
fi

#更新数据库到最大版本
/usr/bin/php $myweb_path/mysqlMigrations/migrate.php  up $db_version
if [ $? -ne 0 ];then
  echo "db update:"$?
  exit 1
fi

#查看迁升后数据库版本列表，及当前数据库版本
/usr/bin/php $myweb_path/mysqlMigrations/migrate.php list

#web切换，给老版本改名，并且新版本程序接手老版本程序开始工作
web_path="/htdocs/myweb"
uploads='/webdir/myweb/uploaded'
if [ -L $web_path ];then
  ln -sfn $(readlink -f "/htdocs/myweb") "/htdocs/myweb_last"
  ln -sfn  $myweb_path $web_path
  echo "$myweb_path   $web_path  ln -s  :"$?
else
  if [ -d $web_path ];then
      mv -f $web_path"/uploaded" $uploads
      mv -f $web_path "/webdir/myweb/myweb_lagacy"
      ln -sfn  $myweb_path $web_path
      ln -sfn "/webdir/myweb/myweb_lagacy" "/htdocs/myweb_last"
  else
    ln -s  $myweb_path $web_path
    if [ ! -d "$uploads" ]; then
        mkdir -p $uploads
        chown -R www-data:www-data  $uploads
    fi
  fi
fi

ln -s  $uploads $myweb_path/uploaded
#赋权限
chown -R www-data:www-data  $myweb_path
#重新加载php5-fpm
/etc/init.d/php5-fpm reload
#nginx应用新配置
nginx=/etc/nginx/sites-enabled/myweb.conf
if [ -f $nginx ];then
 rm $nginx
fi
ln -s $myweb_path/config/myweb.conf $nginx
#nginx加载新配置
/etc/init.d/nginx reload
#删除临时文件
rm -rf /tmp/myweb.*
echo "/tmp/myweb.* rm -rf:"$?