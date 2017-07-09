#!/bin/bash

# get  ban ip
grep "Failed" /var/log/secure | awk '/Failed/{print $(NF-3)}' | sort | uniq -c | awk '{print $2}' > /tmp/ban.txt

# new ip count
NEW_IP_COUNT=`cat /tmp/ban.txt | wc -l`
# old ip count
OLD_IP_COUNT=`tail -1 /var/log/ban.log | awk '{print $6}'`

# if new ip count != old ip count restart sshd
if [ $NEW_IP_COUNT -ne $OLD_IP_COUNT ]; then
    # clear deny
    echo '' > /etc/hosts.deny

    # write ban ip to ssd conf deny
    for line in `cat /tmp/ban.txt`
    do
	echo sshd:$line >> /etc/hosts.deny
    done

    # restart sshd
    service sshd restart
fi

# echo log
echo [`date "+%Y-%m-%d %H:%M:%S"`] ban ip count `cat /tmp/ban.txt | wc -l` >> /var/log/ban.log
# end
