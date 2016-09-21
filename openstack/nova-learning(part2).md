# 4.Liberty代码学习 #
## 4.1 nova各服务启动入口 ##
以nova-api举例：
- ps -ef | grep nova得到结果：
```
nova      18313      1  0 Sep07 ?        00:05:51 /usr/bin/python /usr/bin/nova-network
nova      25308      1  1 Sep07 ?        00:32:19 /usr/bin/python /usr/bin/nova-api
nova      25312      1  0 Sep07 ?        00:00:54 /usr/bin/python /usr/bin/nova-novncproxy --web /usr/share/novnc/
nova      25322      1  1 Sep07 ?        00:31:18 /usr/bin/python /usr/bin/nova-conductor
nova      25328      1  0 Sep07 ?        00:03:01 /usr/bin/python /usr/bin/nova-scheduler
nova      25341      1  0 Sep07 ?        00:02:40 /usr/bin/python /usr/bin/nova-consoleauth
nova      25357      1  0 Sep07 ?        00:02:39 /usr/bin/python /usr/bin/nova-cert
nova      25364  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nova      25365  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nova      25366  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nova      25367  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nova      25368  25322  0 Sep07 ?        00:06:43 /usr/bin/python /usr/bin/nova-conductor
nova      25369  25322  0 Sep07 ?        00:08:45 /usr/bin/python /usr/bin/nova-conductor
nova      25370  25322  0 Sep07 ?        00:08:39 /usr/bin/python /usr/bin/nova-conductor
nova      25371  25322  0 Sep07 ?        00:08:38 /usr/bin/python /usr/bin/nova-conductor
nova      25378  25308  0 Sep07 ?        00:01:18 /usr/bin/python /usr/bin/nova-api
nova      25379  25308  0 Sep07 ?        00:01:18 /usr/bin/python /usr/bin/nova-api
nova      25381  25308  0 Sep07 ?        00:01:15 /usr/bin/python /usr/bin/nova-api
nova      25382  25308  0 Sep07 ?        00:01:15 /usr/bin/python /usr/bin/nova-api
nova      25390  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nova      25391  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nova      25392  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nova      25393  25308  0 Sep07 ?        00:00:00 /usr/bin/python /usr/bin/nova-api
nobody    26236      1  0 Sep07 ?        00:00:00 /sbin/dnsmasq --strict-order --bind-interfaces --conf-file= --pid-file=/var/lib/nova/networks/nova-gw-b38fcd66-20.pid --dhcp-optsfile=/var/lib/nova/networks/nova-gw-b38fcd66-20.opts --listen-address=203.0.113.25 --except-interface=lo --dhcp-range=set:demo-net,203.0.113.26,static,255.255.255.248,86400s --dhcp-lease-max=8 --dhcp-hostsfile=/var/lib/nova/networks/nova-gw-b38fcd66-20.conf --dhcp-script=/usr/bin/nova-dhcpbridge --no-hosts --leasefile-ro --domain=novalocal --addn-hosts=/var/lib/nova/networks/nova-gw-b38fcd66-20.hosts
root      26237  26236  0 Sep07 ?        00:00:00 /sbin/dnsmasq --strict-order --bind-interfaces --conf-file= --pid-file=/var/lib/nova/networks/nova-gw-b38fcd66-20.pid --dhcp-optsfile=/var/lib/nova/networks/nova-gw-b38fcd66-20.opts --listen-address=203.0.113.25 --except-interface=lo --dhcp-range=set:demo-net,203.0.113.26,static,255.255.255.248,86400s --dhcp-lease-max=8 --dhcp-hostsfile=/var/lib/nova/networks/nova-gw-b38fcd66-20.conf --dhcp-script=/usr/bin/nova-dhcpbridge --no-hosts --leasefile-ro --domain=novalocal --addn-hosts=/var/lib/nova/networks/nova-gw-b38fcd66-20.hosts
root      34587  25043  0 Sep08 pts/2    00:13:21 python -m pdb /usr/bin/nova-compute --config-file /etc/nova/nova.conf --debug --verbose
root      34623  13787  0 Sep08 pts/1    00:00:00 vi nova/compute/manager.py
```
可以看到，nova-api服务启动的脚本是/usr/bin/nova-api，配置文件是/etc/nova/nova.conf，日志在/var/log/nova/nova-api.log

- vi /usr/bin/nova-api
```
#!/usr/bin/python
# PBR Generated from u'console_scripts'
import sys
from nova.cmd.api import main
if __name__ == "__main__":
    sys.exit(main())
```
可以看到：nova-api服务启动的入口点是/nova/cmd/api.py的main函数。
同理，可以知道：
 - nova-compute服务启动的入口点是/nova/cmd/compute.py的main函数。
 - nova-scheduler服务启动的入口点是/nova/cmd/scheduler.py的main函数。
 - nova-conductor服务启动的入口点是/nova/cmd/conductor.py的main函数。

## 4.2 nova.conf配置文件 ##
[http://docs.openstack.org/developer/nova/sample_config.html](http://docs.openstack.org/developer/nova/sample_config.html)
/etc/nova/nova.conf
