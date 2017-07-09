#!/bin/bash

# env info
env_info(){
    # centos 7
    PRI_IP=`/sbin/ifconfig | grep "inet" | awk -F' ' '{print $2}' | awk '{print $1}' | grep "10\.\|127\.\|192\." | sed -n 1p`
    # centos 6
    # PRI_IP=`/sbin/ifconfig | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}' | grep "10\.\|127\.\|192\." | sed -n 1p`
    if [ ! -z $PRI_IP ]; then
	if [ -d $PWD/$PRI_IP ];then
            rm -rf $PWD/$PRI_IP
	fi
	mkdir -p $PWD/$PRI_IP
	STAT=`whereis iostat | awk -F ":" '{print $2}' | awk '{print $1}'`
	if [ ! -f $STAT ]; then
	    yum -y install sysstat
	fi
    else
	echo "IP address is null."
	exit -1
    fi
}

# system info
sys_info(){
    echo "sysip : $PRI_IP" | tee $SYSINFO
    echo "starttime : $TIME" | tee -a $SYSINFO
    /sbin/ifconfig >> $SYSINFO
    echo "===================================" >> $SYSINFO
    /usr/sbin/dmidecode >> $SYSINFO
    echo "===================================" >> $SYSINFO
    /bin/cat /proc/cpuinfo >> $SYSINFO
    echo "===================================" >> $SYSINFO
    /sbin/fdisk -l >> $SYSINFO
    echo "===================================" >> $SYSINFO
    /bin/df -Th >> $SYSINFO
    echo "===================================" >> $SYSINFO
    /usr/bin/free -m >> $SYSINFO
    echo "===================================" >> $SYSINFO
    echo ""
}
# get runtime info
info(){
    $SAR -P ALL $INTERVAL $TIMES>> $CPUUSAGE 
    $IOSTAT -dkx $INTERVAL $TIMES>> $DISKUSAGE
    $SAR -n DEV $INTERVAL $TIMES>> $NETWORK
    $SAR -r $INTERVAL $TIMES>> $MEMUSAGE
    for ((i=0;i<$TIMES;i++))
    do
        sleep $INTERVAL
    done
}


# main function
main(){
    TIMES=10
    INTERVAL=2
    PWD=`pwd`
    TIME=`date "+%F %H:%M:%S"`
    TAR=`whereis tar | awk -F ":" '{print $2}' | awk '{print $1}'`
    SAR=`whereis sar | awk -F ":" '{print $2}' | awk '{print $1}'`
    IOSTAT=`whereis iostat | awk -F ":" '{print $2}' | awk '{print $1}'`

    # function
    env_info
    SYSINFO=$PWD/$PRI_IP/sysinfo
    sys_info
    CPUUSAGE="$PWD/$PRI_IP/cpuusage.log"
    MEMUSAGE="$PWD/$PRI_IP/memusage.log"
    DISKUSAGE="$PWD/$PRI_IP/diskusage.log"
    NETWORK="$PWD/$PRI_IP/network.log"
    info
}
main
