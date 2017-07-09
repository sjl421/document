#!/bin/bash

#set -x

# 变量
script=iam
lock_name=labcloud_iam
pid_name=labcloud_iam.pid
log_name=labcloud_iam.`date "+%Y-%m-%d"`.log
log_path=.

lock_path=/var/lock
pid_path=/var/run

# lock
lockfile=${lock_path}/${lock_name}

# pid
pidfile=${pid_path}/${pid_name}

# jar
jar_file=`ls target/labcloud*.jar`

# command
command="nohup java -jar"

# logfile
logfile=${log_path}/${log_name}

# 启动
start() { 
	if [ -f ${lockfile} ]; then
		echo "${script} is running"
		exit 1
	fi
	if [ ! -f ${jar_file} ]; then
		echo "jar file is not exist,maybe 'mvn package' failed.	[Failed]"
		exit 2
	else
		echo -n "starting ${script} service..."
		${command} ${jar_file} >> ${logfile} 2>&1 &
		sleep 5
		# 判断pid是否存在
		pid=`ps -fe | grep ${jar_file} | grep -v grep | awk '{print $2}'`
		if [ -z ${pid} ]; then
			echo -e "		[Failed]"
			exit 3
		else
			echo ${pid} > ${pidfile}
			touch ${lockfile}
			echo -e "		[OK]"
		fi

	fi
}

# 停止
stop() {
	echo -n "stopping ${script} service..."
	if [ -f ${pidfile} ]; then
		pid=`cat ${pidfile}`
	else
		pid=0
	fi
	id=`ps -fe | grep ${jar_file} | grep -v grep | awk '{print $2}'`
	if [ -z ${id} ]; then
		echo "${script} service not running"
	else
		if [ ${pid} -ne ${id} ]; then
			echo -e "		[Failed]"
			exit 4
		else
			kill -9 ${id}
			rm -f ${pidfile}
			rm -f ${lockfile}
			echo -e "		[OK]"
		fi
	fi
} 

# 重启
restart() { 
	if [ -f ${lockfile} ]; then
		stop 
		sleep 5
		start
	else
		echo "${script} service not running."
		start
	fi
}

# 状态
status() { 
	if [ -f ${pidfile} ]; then
		pid=`cat ${pidfile}`
	else
		pid=0
	fi
	id=`ps -fe | grep ${jar_file} | grep -v grep | awk '{print $2}'`
	if [ -z ${id} ]; then
		echo "${script} service not running.		[Failed]"
		exit 5
	fi
	if [ ${pid} -eq ${id} ]; then
		echo "${script} service is running.		[OK]"
	else
		echo "${script} service not running.		[Failed]"
		exit 6
	fi
}

case "$1" in
        'start')
                start
        ;;
        'stop')
                stop
        ;;
        'restart')
                restart
        ;;
        'status')
                status
        ;;
        *)
        echo "Usage:$0{start|stop|restart|status|}"
        ;;
esac

exit 0
