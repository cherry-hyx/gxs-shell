#!/bin/bash
#Shell Command For Backup MySQL Database Everyday Automatically By Crontab

PATH=/usr/local/mysql/bin:$PATH:/data/bin:$PATH:$HOME/bin
export PATH

USER=root
PASSWORD="123456"
#DATABASES="stocksir"
DATABASES="stocksir agency agency_sys"
HOSTNAME="1**"

WEBMASTER=hjb.123@163.com

BACKUP_DIR=/home/mysql/mysql_back/ #备份文件存储路径
LOGFILE=/home/mysql/mysql_back/data_backup.log #日记文件路径
DATE=`date '+%Y%m%d-%H%M'` #日期格式（作为文件名）
DUMPFILE=$DATE.sql #备份文件名
ARCHIVE=$DATE.sql.tgz #压缩文件名
#OPTIONS="-h$HOSTNAME -u$USER -p$PASSWORD $DATABASE"
#mysqldump －help

#判断备份文件存储目录是否存在，否则创建该目录
if [ ! -d $BACKUP_DIR ] ;  then
        mkdir -p "$BACKUP_DIR"
fi

#开始备份之前，将备份信息头写入日记文件
echo " " >> $LOGFILE
echo " " >> $LOGFILE
echo "———————————————–" >> $LOGFILE
echo "BACKUP DATE:" $(date +"%y-%m-%d %H:%M:%S") >> $LOGFILE
echo "———————————————– " >> $LOGFILE

#切换至备份目录
cd $BACKUP_DIR
#使用mysqldump 命令备份制定数据库，并以格式化的时间戳命名备份文件
for DATABASE in $DATABASES
	do
	OPTIONS="-h$HOSTNAME -u$USER -p$PASSWORD --set-gtid-purged=OFF --single-transaction --default-character-set=utf8 --flush-logs --master-data=1 -R  $DATABASE"
	DUMPFILE=${DATE}_${DATABASE}.sql #备份文件名
	mysqldump $OPTIONS > $DUMPFILE 2>> $LOGFILE
	#判断数据库备份是否成功
	if [ $? -eq 0 ]; then
		#输入备份成功的消息到日记文件
		echo "[${ARCHIVE}] Backup Successful!" >> $LOGFILE
		#删除原始备份文件，只需保 留数据库备份文件的压缩包即可
	else
		echo "Database Backup Fail!" >> $LOGFILE
	fi
	sleep 2
	#输出备份过程结束的提醒消息
done

cd $BACKUP_DIR
#创建备份文件的压缩包
tar czf $ARCHIVE $DATE_*.sql >> $LOGFILE 2>&1
rm -f $DATE_*.sql

echo "Backup Process Done"  >> $LOGFILE
echo "———————————————– " >> $LOGFILE