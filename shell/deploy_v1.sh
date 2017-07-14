#!/usr/bin/env bash

######################
##2017.06.27####
## by cherry
##部署程序
#        \$1 newdeploy deploy back rollback
#        \$2 部署应用名
#        \$3 部署目录(绝对路径)
#        \$4 部署压缩包 当为rollback时，不指定。
######################

##帮助信息
helpinfo() {
	cat <<EOF
        \$1 newdeploy deploy back rollback
        \$2 部署应用名
        \$3 部署目录(绝对路径)
        \$4 部署压缩包 当为coback时为备份包
EOF
}

if [ -z "$3" ] ; then
	echo "参数错误：缺少参数！"
    helpinfo
	exit 1
fi

#部署压缩包
tarfile="$4"
#部署目录(绝对路径),
projectdir="$3"

if [ "${projectdir:0-1:1}" == "/" ];then
    projectdir=${projectdir::-1}
fi

project="$2"
echo "部署的应用为：${project}"

###指定备份时不打包的文件或目录####
excludes="--exclude=upload/* --exclude=cache/* --exclude=vendor --exclude=storage/* --exclude='*.log'"
##解压临时目录
tmpdir=/tmp/${project}
backuproot=/home/app/backup


##执行是否成功
function isok {
        if [ $? -ne 0 ];then
                echo "$1 出错了"
                exit 1
        fi
}

#解压包
#$1 压包
#$2 解压目录
extract() {
    if [ -f $1 ] ; then
      	case $1 in
        	*.tar.gz)    tar xzf $1  -C $2	1>/dev/null || (echo "'$1' cannot be extracted $1" ;exit 1) ;;
        	*.zip)       unzip $1   -d $2  1>/dev/null  || (echo "'$1' cannot be extracted $1" ;exit 1) ;;
        	*)
				echo "'$1' cannot be extracted via extract()"
				exit 1 ;;
        esac
     else
        echo "'$1' is not a valid file"
        exit 1
    fi
}

##部署
deploy() {
	##$projectdir  部署目录
	##${hosts} 部署服务器 a;b;c多台，如果不指定，部署到本机
	cd /tmp
	filenum=`du -b /tmp/${tarfile} | awk '{print $1}'`
	if [ $filenum -lt 45 ] ;then
	    echo "压缩包为空!请查看包文件！"
	    exit 1
	fi
	if [ ! -d ${tmpdir} ];then
	    mkdir -p ${tmpdir}
	fi
	echo "部署目录：${projectdir}"
	cd ${tmpdir} && rm -rf * >/dev/null 2>&1
	cd /tmp && extract ${tarfile} ${tmpdir} && cd ${tmpdir} && \cp -R * ${projectdir} >/dev/null 2>&1
}

newdeploy(){
    if [ -d ${projectdir} ] ;then
        echo "目录已经存在，请确认这为新建应用目录"
        exit 1
    else
        mkdir -p ${projectdir}
        deploy
    fi
}




##执行回滚
rollback() {
	cd $backuproot/${project}
	echo "应用目录:${projectdir}"
	cobackfile=`ls -lrt  ${project}*.tar.gz | tail -n1 | awk '{print $NF}'`
	extract ${cobackfile} ${projectdir}
}

##解压其它格式
extract2 () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1  	;;
        *.tar.gz)    tar xzf $1 	;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)
			echo "'$1' cannot be extracted via extract()"
			exit 1
			;;
         esac
     else
         echo "'$1' is not a valid file"
         exit 1
     fi
}


##删除历史备份包
delbackfile(){
	##只保留5份备份文件
	cd ${backuproot}/${project}
	echo "备份目录：$PWD"
	isok
	tmpnum=`ls -lrt ${project}*.tar.gz | wc -l`
    if [ $tmpnum -gt 5 ] ;then
        ls -lrt  *.tar.gz | head -n$(( $tmpnum - 5 )) | awk '{print $NF}' | while read line
        do
              echo "删除历史备份文件$line"
              rm -rf $line
        done
	fi

}


##执行备份
backup() {
    backdir=${backuproot}/${project}
    if [ ! -d  ${backdir} ];then
        mkdir -p ${backdir} || ( echo "新建备份目录${backdir}失败！";exit 1)
    fi
    backfilename=${project}_$(date "+%Y%m%d-%H%M%S").tar.gz
	if [[ x${backuproot} == x/ ]]  ;then
		echo "部署不能目录为/！！"
		exit 1
	fi
    cd ${projectdir}
    #删除log日志
    find . -name "*.log" -type f -mtime +7 | xargs rm -rf
    tar zcf ${backdir}/${backfilename} ${excludes} *  && echo "备份${app}成功! 备份文件为:${backfilename}" || (echo "备份${app}失败！";exit 1)
    delbackfile
}


case $1 in
	"newdeploy")
	    echo "开始新建"
		if [ -z "$4" ];then
		    echo "新建部署需要的包必须指定!!!"
		    exit 1
		fi
		newdeploy
		if [ $? -eq 0 ];then
		    echo "新建成功"
		else
		    echo "新建失败"
		fi
		echo"" ;;
	"deploy")
	    echo "开始部署"
		if [ -z "$4" ];then
		    echo "部署需要的包必须指定!!!"
		    exit 1
		fi
		deploy
		if [ $? -eq 0 ];then
		    echo "部署成功"
		else
		    echo "部署失败"
		fi
		echo"" ;;
	"backup")
	    echo "开始备份"
		backup
		if [ $? -eq 0 ];then
		    echo "备份成功"
		else
		    echo "备份失败"
		fi
		echo"" ;;
	"rollback")
	    echo "开始回滚"
		rollback
		if [ $? -eq 0 ];then
		    echo "回滚成功"
		else
		    echo "回滚失败"
		fi
		echo"" ;;
	*)
		echo "参数1只能为：newdeploy,deploy,backup,rollback !!!"
		exit 1;;
esac

exit 0
