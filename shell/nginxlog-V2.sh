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

webs='clb content.api h5.api h5api.api login.api manager  managertps merchants pay.api seller.api tps.api static trade.api u.api'

function mvlog {

for web in $webs
do
        echo "mv ${web}"
        mv ${LOGS_PATH}/${web}-access.log ${DATA_LOGS_PATH}/${DATA_YESTERDAY}/${web}_access.log
done
## 移动文件

## 向 Nginx 主进程发送 USR1 信号。USR1 信号是重新打开日志文件
kill -USR1 $(cat /var/run/nginx/nginx.pid)

}

function sortlogs {
for web in $webs
do
        num=`more ${DATA_LOGS_PATH}/${DATA_YESTERDAY}/${web}_access.log | wc -l`
        size=`head -n400 ${DATA_LOGS_PATH}/${DATA_YESTERDAY}/${web}_access.log  | awk 'BEGIN{s=0} {s=s+$(NF-1)} END {print s/$NR/1024}'`
        echo "${web}   ${num}   ${size}" >> /root/script/webs/${YESTERDAY}.txt
done
}

if [  -z "$1"  ];then
        mvlog
        sortlogs
elif [ "x$1" == "xmvlog" ]; then
        mvlog
elif [ "x$1" == "xsortlogs" ]; then
        sortlogs
else
        echo "$1 error!!! mvlog or sortlogs!!!"
        exit 1
fi
exit 0