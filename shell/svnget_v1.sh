#!/bin/sh
######################
##2017.06.27####
## by cherry
## SVN拉取部署程序
## $1 部署项目
## $2 更新版本
## $3 部署版本
## $4 不打包文件
#svn 更新
#
#svn up --username zhangsan --password 123456
#svn update -r 200 test.php(将版本库中的文件test.php还原到版本200)
#svn update test.php
#svn update --set-depth=exclude tags branches 排除目录

######################

##查看版本段修改文本svn diff -r 211:224|grep -i Index:| awk -F : '{print $2}' | grep -v "^\s\.$"
##打包svn diff -r 2577:head |grep -i Index:| awk -F : '{print $2}' | grep -v "^\s\.$" | xargs tar -zcvf /tmp/t.tar.gz

excludes=" --exclude=.svn --exclude=upload --exclude=.env --exclude=payment --exclude=data/cache  --exclude=log.php --exclude=autoload.php --exclude=storage --exclude=config/*  --exclude=test.php --exclude='*.log' "
excludes=" --exclude=.svn --exclude=upload/* --exclude=.env --exclude=data/cache  --exclude='*.log' "
oldpwd=$PWD

if [ -z "$1" ]  ;then
	echo "****部署项目不能为空！！"
	exit 1
fi

if [ -z "$2" ]  ;then
	echo "****更新版本不能为空！！"
	exit 1
fi

if [ -z "$3" ]  ;then
	echo "****部署版本不能为空！！"
	exit 1
fi

proj="$1"       #SVN url部分
newversion=$2   #更新到某个版本
upverson=$3     #上传某些版本的内容
excludes_p=$4   #额外不上传的文件,可以为空
ext_cludes=""

##需要排除的所有无用目录和文件exclude
for temp in `echo $excludes_p | tr -s ',' ' '`
do
	ext_cludes="${ext_cludes} --exclude=${temp}"
done

tmpdir=/data/script/tmp
baseurl=https://192.168.0.223:8443/svn
endurl=trunk

svnbasedir=/home/svndata
localdir=trunk
tardir=/home/svndata/upload

filetmp=trunk

if [[ "${proj}"  == "h5.stocksir" ]] ;then
	endurl=trunk/app
	localdir=app
	filetmp=trunk/app
fi

if [[ "${proj}"  == "newh5" ]] ;then
    proj=h5v1.0
fi

if [[ "${proj}"  == "wxlgd" ]] ;then
        proj=weixin_lgd
fi


svnurl=${baseurl}/${proj}/${endurl}
echo "----SVN地址：${svnurl}"

##执行是否成功
function isok {
        if [ $? -ne 0 ];then
                echo "$1"
                exit 1
        fi
}

#更新到版本号
updatesvn(){
    echo "执行更新："
    if [ ! -d "${svnbasedir}/${proj}/${localdir}" ]; then
        createsvndir
    fi
     cd ${svnbasedir}/${proj}/${localdir}
     /usr/bin/svn cleanup >/dev/null 2>&1
     /usr/bin/svn update -r ${newversion} >/dev/null 2>&1 || isok "更新${localdir}失败"
     echo "SVN更新成功，版本更新到:`svn info | head -n6 | tail -n1`"
}

#$1 建立SVN工作目录
createsvndir(){
    mkdir -p ${svnbasedir}/${proj}
    cd ${svnbasedir}/${proj} && rm -rf *
    /usr/bin/svn checkout ${svnurl} >/dev/null && echo "新建SVN项目${proj}成功!"
    if [ $? -ne 0 ];then
        echo "新建SVN项目${proj}失败!"
        rm -rf ${svnbasedir}/${proj}
        exit 1
    fi
}

##打包文件
##$1 版本号 如果为空进行全量
##先打包到零时目录，再进行gzip压缩
tarfile(){
    cd ${svnbasedir}/${proj}/${localdir} || isok "无打包目录!退出"
    chmod -R 755 *
    echo "----打包目录:$PWD"
    rm -rf ${tardir}/${proj}.tar* >/dev/null 2>&1
    if [ -z "$1" ];then
        echo "全量打包"
        echo "----不打包：${ext_cludes} "
        tar zcf ${tardir}/${proj}.tar.gz ${ext_cludes} * >/dev/null 2>&1
    else
        echo "----不打包：${excludes} ${ext_cludes} "
#        svn diff -r $1 | grep -i Index:| awk -F : '{print $2}' | grep -v "^\s\.$" | xargs tar zcf ${tardir}/${proj}.tar.gz >/dev/null 2>&1
#        svn -r 380:head log -v | grep -P  '^\s+(M|A)' | awk '{print $2}' | sort | uniq | sed "s#/trunk/##"

        echo > /${tmpdir}/${proj}_tmp.txt
        for x in `echo $1 | tr -s ',' ' '`
        do
            echo "打包版本：${x}"
#           svn diff -r ${x} | grep -i Index:| awk -F : '{print $2}' | grep -v "^\s\.$" | xargs tar -rf ${tardir}/${proj}.tar ${excludes} ${ext_cludes} >/dev/null 2>&1
            svn log -v -r ${x} | grep -P  '^\s+(M|A)' | awk '{print $2}' | sed "s#/${filetmp}/##" | sed "s#/trunk##" >> /${tmpdir}/${proj}_tmp.txt || exit 1
        done

        cat /${tmpdir}/${proj}_tmp.txt | sort | uniq > /${tmpdir}/${proj}_tmp1.txt

        echo > /${tmpdir}/${proj}.txt
        while read line
        do
        if [  -f ${svnbasedir}/${proj}/${localdir}/$line  ];then
                echo $line >> /${tmpdir}/${proj}.txt
        fi
        done < /${tmpdir}/${proj}_tmp1.txt

#        filenum=`du -b ${tardir}/${proj}.tar.gz | awk '{print $1}'`
        filenum=`cat /${tmpdir}/${proj}.txt | wc -l`
        if [ $filenum -eq 0 ] ;then
            echo "上传内容!请查看更新版本！"
            exit 1
        fi
        echo "更新文件:"
        cat /${tmpdir}/${proj}.txt
        echo
        tar zcf ${tardir}/${proj}.tar.gz ${excludes} ${ext_cludes}  -T /${tmpdir}/${proj}.txt
    fi
}


updatesvn
####全量更新！
if [[  "$upverson" == "all" ]] ||  [[  "$upverson" == "ALL" ]];then
    tarfile
else
    tarfile ${upverson}
fi

cd $oldpwd
exit 0
