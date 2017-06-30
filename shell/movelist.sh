#!/bin/sh
list="asyn.api  clb.api  content.api  h5api.api  login.api  pay.api  seller.api  tps.api  trade.api  u.api"
# cd /data/www/ && tar zcf list.tar.gz --exclude=*.log --exclude=config $list
mkdir /data/bak_api
for q in $list
do
	mv /data/www/$q /data/bak_api/
done

tar zxf list.tar.gz -C /data/www
for q in $list
do
	mkdir -p /data/www/$q/app/data/config
	cp /data/bak_api/$q/app/data/config/* /data/www/$q/app/data/config 
done


