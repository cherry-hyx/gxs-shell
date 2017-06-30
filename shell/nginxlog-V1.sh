#!/bin/bash
## 零点执行该脚本
## Nginx 日志文件所在的目录
LOGS_PATH=/var/log/nginx/logs
DATA_LOGS_PATH=/var/log/nginx/data
## 获取昨天的 yyyy-MM-dd
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
DATA_YESTERDAY=$(date -d "yesterday" +%Y%m%d)
#echo $DATA_YESTERDAY
mkdir -p ${DATA_LOGS_PATH}/$DATA_YESTERDAY
if [ $? -ne 0 ] ;then
        echo "err mkdir!"
        exit 1
fi

web='hq'

function mvlog {

mv ${LOGS_PATH}/${web}-access.log ${DATA_LOGS_PATH}/${DATA_YESTERDAY}/${web}_access.log
mv ${LOGS_PATH}/${web}-error.log ${DATA_LOGS_PATH}/${DATA_YESTERDAY}/${web}_error.log
## 移动文件

## 向 Nginx 主进程发送 USR1 信号。USR1 信号是重新打开日志文件
kill -USR1 $(cat /var/run/nginx/nginx.pid)

}

function sortlogs {
	
	tokennum=`more ${DATA_LOGS_PATH}/${DATA_YESTERDAY}/${web}_access.log | awk '{print $7}' | egrep -v "/quote/.*" |  wc -l`  
	echo "other ${tokennum}" >> /data/script/webs/${YESTERDAY}.txt
	more ${DATA_LOGS_PATH}/${DATA_YESTERDAY}/${web}_access.log | awk '{print $7}' | egrep "/quote/.*" |  awk -F '&' '{print $2}' | awk -F '=' '{tmp[$2]++;allnu++} END { for ( x in tmp ) print x,tmp[x]; print "all\t",allnu}' >> /data/script/webs/${YESTERDAY}.txt
}

mvlog
sortlogs
exit 0