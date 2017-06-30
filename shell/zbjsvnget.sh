#!/bin/sh
######################
##2017.04.07####
## by cherry
##部署程序
## $1 SVN程序
#svn 更新
#
#svn up --username zhangsan --password 123456
#svn update -r 200 test.php(将版本库中的文件test.php还原到版本200)
#svn update test.php
#svn update --set-depth=exclude tags branches 排除目录 

######################

. ./config.sh

#base_excludes=" --exclude=.svn --exclude=upload --exclude=.env --exclude=payment --exclude=cache --exclude=vendor --exclude=log.php --exclude=storage --exclude=config  --exclude=test.php --exclude='*.log' "
base_excludes=" --exclude=.svn --exclude=upload --exclude=.env --exclude=data/cache --exclude=vendor --exclude=storage --exclude=config  --exclude='*.log' "
oldpwd=$PWD

if [ $# -lt 4 ] ; then
	echo "****参数错误！！"
	exit 1
fi

tmp_odir="$1_$2_dir"
tmp_url="$1_$2_svn"
tmp_local="$1_$2_local"

svnurl="$(eval echo \$${tmp_url})"
localdir="$(eval echo \$${tmp_local})"

tardir=/home/svndata/upload
svnversion=/data/svndata/version
filetmp=$2
proj="$1$2"

if [ -z "${proj}" ] ;then
	echo "****部署项目名不能为空！！"
	exit 1
fi

####要么更新到某个版本号，要么更新到最新！
echo "----SVN地址：${svnurl}"
if [ -d $localdir ];then
	cd $localdir/${filetmp} && /usr/bin/svn cleanup
	cd $localdir/${filetmp} && /usr/bin/svn update -r $3 >/dev/null
	echo "----目录已存在,SVN版本更新到:`svn info | head -n6 | tail -n1`"
else
	mkdir  $localdir && cd $localdir
	/usr/bin/svn checkout  ${svnurl} >/dev/null &&  cd $localdir/${filetmp} && /usr/bin/svn update -r $3 >/dev/null
	echo "----创建工作目录,SVN版本更新到:`svn info | head -n6 | tail -n1`"
fi

##需要排除的所有无用目录和文件tmp_exclude
tmp_exclude=""
for temp in `echo $5 | tr -s ',' ' '` 
###根据上面配置组装
do
	tmp_exclude="${tmp_exclude} --exclude=${temp}"
done

##进入需要打包的目录，打包
cd $localdir/${filetmp}
chmod -R 755 $localdir/${filetmp}
echo "----打包目录:$PWD"
echo "----不打包：${base_excludes} ${tmp_exclude}"

####全量更新！
if [[  "$4" == "all" ]] ||  [[  "$4" == "ALL" ]];then
	tar zcf ${tardir}/${proj}.tar.gz ${base_excludes} ${tmp_exclude} *
	########	
	##保存版本号到${svnversion}/${proj}_HEAD.txt文件中。
	svn  log -l1 -v | head -n2 | tail -n1 | cut -d" " -f1 >> ${svnversion}/${proj}_HEAD.txt
	cd $oldpwd
	exit 0  
fi

####增量更新到最新！
if [[  "$3" == "HEAD" ]] ||  [[  "$3" == "head" ]];then
	cat /dev/null > ${svnversion}/${proj}_file.txt
	oldversion=`cat ${svnversion}/${proj}_HEAD.txt 2>/dev/null | tail -n1`
	newversion=`svn  log -l1 -v | head -n2 | tail -n1 | awk '{print $1}'`	
	echo "----oldversion:" "${oldversion}" "----->" "newversion" "${newversion}"
	if [ -z "${oldversion}" ] || [[ "${oldversion}" == "${newversion}" ]];then
		tar zcf ${tardir}/${proj}.tar.gz ${base_excludes} ${tmp_exclude} *
	else
		echo $oldversion
		#svn -r ${oldversion}:HEAD log -v | grep -P  '^\s+(M|A)' | awk '{print $2}' 
		svn -r ${oldversion}:HEAD log -v | grep -P '^\s+(M|A)' | awk '{print $2}' | sed "s#/${filetmp}/##" | sort | uniq | tee  ${svnversion}/${proj}_file.txt 
		tar zcf ${tardir}/${proj}.tar.gz ${base_excludes} ${tmp_exclude} -T ${svnversion}/${proj}_file.txt 
	fi
	if [ $? -eq 0 ] ; then
		echo "${newversion}" >> ${svnversion}/${proj}_HEAD.txt
	fi
	cd $oldpwd
	exit 0  
fi

####更新某个版本的某些文件
cat /dev/null > ${svnversion}/${proj}_file.txt
for x in `echo $3 | tr -s ',' ' '` 
###根据上面配置组装
do
	svn -r ${x} log -v | grep -P  '^\s+(M|A)' | awk '{print $2}' | sed "s#/${filetmp}/##" >> ${svnversion}/${proj}_file.txt
done
sort -u ${svnversion}/${proj}_file.txt -o  ${svnversion}/${proj}_file.txt
cat ${svnversion}/${proj}_file.txt
tar zcf ${tardir}/${proj}.tar.gz ${base_excludes} ${tmp_exclude} -T ${svnversion}/${proj}_file.txt 
chmod -R 755 ${tardir}/${proj}.tar.gz


cd $oldpwd
exit 0