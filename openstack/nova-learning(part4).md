# 5	创建实例流程分析 #
[api格式](http://developer.openstack.org/api-ref-compute-v2.1.html)
[命令行](http://docs.openstack.org/cli-reference/content/)
[基本概念](http://developer.openstack.org/api-guide/compute/general_info.html)

## 5.1创建实例介绍 ##
即创建一台虚拟机。
- nova会首先在API层完成消息的校验，再将请求调度到合适的计算节点。
- 计算节点上的nova-compute进程，会连同从cinder获取的挂卷信息，以及从neutron获取到的网络信息，一并发送到底层hypervisor去创建VM。
- hypervisor层会完成从glance下载镜像的过程。

### 5.1.1 API映射命令行 ###

REST VERB | URI | 描述
--------- | --- | ----
POST | /v2.1/{tenant_id}/servers | 创建虚拟机

### 5.1.2 相关配置 ###
- 创建虚拟机时，多个port不能属于同一个network
- 指定的网络三参数中，port优先级最高；指定ip时必须指明network
- 若计算节点qemu-nbd服务异常，会导致虚拟机密码等功能不生效
- 注入文件失败，将导致创建VM失败
- 批创建虚拟机时，不支持指定port，指定IP，挂卷启动等功能
- 创建ISO VM，所有的规格需包括临时卷。否则会提示无法找到磁盘
- ISO VM创建后，请尽快导出镜像。防止临时卷丢失

### 5.1.3 配置文件 ###
