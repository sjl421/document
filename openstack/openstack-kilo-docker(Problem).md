# Openstack(kilo)+Docker 遇到问题汇总 #
## 1.keystone报错 ##
>随机token权限不够

~~pipeline = cors sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension_v3 s3_extension service_v3~~

pipeline = cors sizelimit url_normalize request_id admin_token_auth build_auth_context token_auth json_body ec2_extension_v3 s3_extension service_v3

## 2.nova报错 ##
>TypeError: __init__() takes at least 2 arguments (1 given)

```
vi /etc/nova/nova.conf
#firewall_driver = nova.virt.libvirt.firewall.IptablesFirewallDriver
```
>nova.api.openstack AttributeError: id

```
pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com requests -U
pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com 'urllib3>=1.8.3,<1.11'
pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com 'python-glanceclient==0.17.3'
```
重启nova
```
systemctl restart openstack-nova-api.service openstack-nova-cert.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service
```
nova compute报如下错误
>ConnectionError: ('Connection aborted.', error(13, 'EACCES'))

```
/usr/bin/nova-compute --config-file /etc/nova/nova.conf
```
