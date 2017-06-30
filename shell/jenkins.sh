#!/usr/bin/env bash

function isok
{
  if [ $? -eq 0 ];then
 	echo "${1} 部署成功!"
  else
    echo "${1} 部署失败!"
    exit 1
  fi
}

####判断由jenkins上传的参数是否合理
if [ -z "$appname" ] ;then
	echo "应用名不能为空！"
    exit 1
fi

app="-a $appname"


if [ "$isback" == "true" ];then
    back="-b"
else
    back=""
fi


if [ "$deploy" == "newdeploy" ] ; then
    act="-n"
    back=""
    exclude=""

fi

#只要不是回滚状态，都会进行svn代码收集
if [ "$deploy" == "rollback" ];then
    act="-r"
    back=""
else
    echo "......开始代码上传和部署..."
    echo " ${app} ${act} ${back} "
    echo ">>>>>>>>开始收集本地 ${appname} 的代码..."
    /bin/sh  /data/script/svngetfile.sh  ${appname} ${version}  ${up} ${exclude} || exit 1
    echo -e "<<<<<<<<本地收集 ${appname} 代码完成！\n"
fi





echo "......代码执行开始！"
/usr/bin/python2.7 /data/script/deploy.py -f /data/script/yfb_config.ini ${app} ${act} ${back}
isok $app
echo "......代码执行结束！"
exit 0