# 4.Liberty代码学习 #
## 4.3 代码结构讲解 ##
### 4.3.1 /nova/cmd ###
下面是各个nova服务启动的入口.

### 4.3.2 /nova ###
- ./service.py

主机上运行所有服务的通用节点基类，所有服务的start位置，包含class Service(service.Service)和class WSGIService(service.Service)。
class Service(service.Service)是普通的服务，/nova/cmd/scheduler.py、/nova/cmd/compute.p y和/nova/cmd/conductor.py的main函数创建和启动的服务都是通过该类。nova-compute、nova-conductor和nova-shceduler在启动时都会注册一个RPC Server，提供基于AMQP实现的RPC机制，提供给其他服务RPC调用接口。
class WSGIService(service.Service)是WSGI服务，只有nova-api的入口/nova/cmd/api.py的main函数创建和启动该类服务。nova-api不用提供给其他服务RPC调用，无需注册RPC Server。

- ./config.py

调用里面的parse_args方法来初始化一些配置，包含日志、options以及rpc

### 4.3.3 /nova/api/ ###
提供nova-api服务。
- ./openstack：nova-manage使用该接口
- ./ec2：不关注
- ./metadata：不关注，目前使用neutron提供的获取元数据的api

 目前nova只提供这三种api服务，/etc/nova/nova.conf中enabled_apis选项设置启动哪几种服务：
 ```
 [DEFAULT]
 enabled_apis=osapi_compute
 ```
- ./openstack/compute/schemas/ API报文格式检查
- ./openstack/compute/views 资源对用户显示的一些方法和数据报文定义

### 4.3.4 /nova/compute ###
提供nova-compute服务。
- ./api.py
 处理关于计算资源的所有的请求，将请求封装成在AMQP消息发送出去，交给./manager.py中的ComputeManager去运行.
- ./rpcapi.py
 其中class ComputeAPI(object)中的函数即为nova-compute服务提供给RPC调用的接口，其他服务调用前需要首先import这个python文件。例如：/nova/conductor/tasks/live_migrate.py中from nova.compute import rpcapi as compute_rpcapi
- ./manager.py
 ./rpcapi.py中ComputeAPI类只是暴露给其他服务的RPC调用接口，真正完成任务的是manager.py。
 manager.py对实例相关的所有进程的处理，其中class ComputeManager(manager.Mana ger)：管理实例从建立到销毁的运行过程；class ComputeVirtAPI(virtapi.VirtAPI)：计算VirtAPI。
 从ComputeAPI到ComputeManager的过程就是通过Queue完成RPC调用过程。
 内置周期性任务，完成资源刷新，虚拟机状态同步等功能。/nova/compute/manager.py中搜索@periodic_task.periodic_task。周期性任务通过绿色线程执行，通过对方法加装饰器来实现。装饰器指定执行的周期间隔，默认60s。

nova-compute中的周期性任务

周期性函数 | 功能 | 周期 | 备注
----------| ---- | ---- | ------
_check_instance_build_time | 检查虚拟机是否卡在building状态，目前不生效。 | 60s | 原生
_heal_instance_info_cache | 从neutron同步port的状态到nova数据库中。 | 60s | 原生
_poll_rebooting_instances | 检查虚拟机是否卡在rebooting状态，目前不生效。 | 60s | 原生
_poll_rescued_instances | 检测虚拟机是否卡在rescued状态，目前不生效。 | 60s | 原生
_poll_unconfirmed_resizes | 虚拟机修改规格后，在一定时间内自动确认，目前不生效。 | 60s | 原生
_poll_shelved_instances | 将shelved的虚拟机的资源删除，目前不生效。 | 3600s | 原生
_instance_usage_audit | 定期通知虚拟机的存在，目前不生效。 | 60s | 原生
_poll_bandwidth_usage | 更新虚拟机网卡带宽的使用，目前不生效。 | 600s | 原生
_sync_power_states | 周期性虚拟机状态的同步。 | 60s | 原生重写
_reclaim_queued_deletes | 软删除虚拟机后删除虚拟机。 | 60s | 原生
update_available_resource | 周期性资源同步任务。 | 60s | 原生
_cleanup_running_deleted_instances | 关闭（或删除）上层已经删除，但是底层残留的虚拟机。 | 600s | 原生
_run_image_cache_manager_pass | 目前不生效 | | 原生
_run_pending_deletes | 删除残留虚拟机的文件 | 300s | 原生

- ./resource_tracker.py和claim.py
实现资源的管理。nova-compute为每一个主机创建一个ResourceTracker类实例来跟踪他的资源。作为OpenStack的资源跟踪器，Resource Tracker负责收集主机上的资源以及将资源使用情况通知nova-scheduler作为选择主机的依据。
Nova使用ComputeNode对象保存计算节点的配置信息以及资源使用状况。nova-compute为每一个主机创建一个ResourceTracker对象，任务就是更新ComputeNode对象在数据库中对应的表compute_nodes。有两种更新数据库中资源的方式：一是使用Claim机制，二是使用周期性任务（Periodic Task）。
 - Claim机制：/nova/compute/resource_tracker.py instance_claim()
 - Periodic Task：/nova/compute/manager.py ComputeManager.update_available_resource()

### 4.3.5 /nova/scheduler ###
调度资源池。
- ./rpcapi.py
 nova-scheduler服务提供给其他服务调用的RPC接口。
- ./manager.py
 实现./rpcapi.py中暴露给其他服务的RPC调用接口
- ./driver
 每一个调度器必须要实现的接口。目前调度器有：ChanceScheduler（随机调度器）、FilterScheduler（过滤调度器）和CachingScheduler，不同的调度器不能共存，需要在/etc/nova/nova.conf中scheduler_driver选项指定。
- ./host_manager.py
 nova-compute对数据的更新是周期性的，而nova-compute在选择最佳主机时则要求数据必须是最新的，因此nova-scheduler中又维护了一份数据，里面包含从上次数据库更新到现在的主机资源变化情况，这部分工作由host_manager.HostState完成

上述功能就是nova-scheduler选中某个host作为destination（select_destinations）后，comsume预占资源。
- ./filter
所有的filter实现，不同的Filter可能共存，具体使用哪些Filter通过/etc/nova/nova.conf中
选项指定，scheduler_available_filters用于指定所有可用的Filters，scheduler_default_filters则表示对于可用的Filter，nova-scheduler默认会使用哪些.
- ./weights
 Weighting是指对于所有符合条件的主机计算权重并排序从而得出最佳的一个
- ./chance.py
- ./caching_scheduler.py
- ./filter_scheduler.py

### 4.3.6 /nova/conductor ###
提供nova-conductor服务.
- ./rpcapi.py
 nova-conductor服务提供给其他服务调用的RPC接口。
- ./api.py
基于数据库访问的特殊性，api.py文件中又对RPC的调用做了一层封装，其它模块需要导入的是api.py，为不是rpcapi.py。
LocalAPI，API：访问数据库的接口。LocalComputeTaskAPI，ComputeTaskAPI：耗时操作的TaskAPI接口。nova-conductor和nova-compute部署在同一个节点时，不需要RPC，此时通过LocalXXX接口，是否适用LocalXXX接口可以通过nova.conf配置文件中use_local选项配置，默认使用非LocalXXX接口。
- ./manager.py
 - 实现./rpcapi.py中暴露给其他服务的RPC调用接口。
 - ConductorTaskManager：主要负责流程调度的类。
 - ConductorManager：主要负责与数据库相关操作的类。

### 4.3.7 /nova/db ###
提供数据库操作。
- ./sqlalchemy/models.py
存入数据库数据的模型，其中每个类对应数据库的一张表，包含数据库对外操作的接口。

### 4.3.8 /nova/objects ###
nova资源的数据模型，里面每一个类都对应数据库中的一个表。功能：
- nova-computer和数据库的在线升级
- 对象属性类型的声明
- 减少写入数据库的数据量

### 4.3.9 /nova/image ###
提供Glance接口抽象。
image管理的代码都在这里。service.py定义了image管理的相关接口，后端有三个driver: glance, local, 和s3. 分别使用不同的后端存储来存放image。
service.BaseImageService定义了image管理的接口。每个成员方法都有详细的描述。

### 4.3.10 /nova/volume ###
Cinder接口抽象。

### 4.3.11 /nova/virt ###
Hypervisor driver。各种Hypervisor的支持通过Virt Driver的方式实现，比如Libvirt Driver，nova-computer通过Libvirt与KVM交互。虚拟化技术如KVM、XEN等，都会有对应的Virt driver。
我们可以使用/etc/nova/nova.conf中compute_driver选项指定使用哪个Virt Driver。
- ./disk
提供一些工具函数。
- ./hyperv
Hyperv
- ./ironic
Baremetal
- ./libvirt
Libvirt
- ./vmwareapi
VMware
- ./xenapi
XenAPI

### 4.3.12 /nova/network ###
不关心。

### 4.3.13 /nova/openstack ###
来自于Oslo的代码.

### 4.3.14 /requirements.txt ###
安装nova服务依赖的环境。

### 4.3.15 /nova/cloudpipe ###
提供VPN服务，为project创建VPN服务器的代码。从代码上看，VPN实际上是云中一个tiny类型的虚拟机，在上面有一个VPN服务器。

### 4.3.16 /nova/console ###
提供nova-novncproxy服务。
入口：/usr/bin/nova-novncproxy。
Nova提供了novncproxy代理支持用户通过vnc访问实例。提供完整的vnc访问功能，涉及几个nova服务：nova-consoleauth提供认证授权，nova-novncproxy用于支持基于浏览器的vnc客户端，nova-xvpncproxy用于支持基于Java的vnc客户端。

### 4.3.17 /nova/consoleauth ###
提供nova-consoleauth服务。
提供nova-novncproxy服务的认证授权。入口：/usr/bin/nova-consoleauth

### 4.3.18 /nova/cells ###
提供nova- cells服务。
Cell模块允许用户在不影响现有OpenStack云环境的前提下，增强横向扩展、大规模部署能力。Cell模块启动后，OpenStack云环境中的主机被划分成组被称为Cell。
nova-cells负责各个Cell之间的通信，以及为一个新的实例选择合适的Cell，因此每个Cell都需要运行nova-cells服务。
总结：cell其实就是openstack社区做的级联，将多个nova模块级联在一起，每个里面都有nova-schedular，/nova/cells里面的filters和weights就是在做cell的选择，创建虚拟机时先选择cell（/nova/cells /filters里面有实例不在相同cell等过滤规则）cell里面的nova-scheduler选择host和node。

### 4.3.19 /nova/cert ###
提供nova-/cert服务：管理X509证书。

### 4.3.20 /nova/ipv6 ###
ipv6地址操作类。

### 4.3.21 /nova/notifier ###
事件通知器，就目前的代码来看，这个通知器好像还没有被使用起来。

### 4.3.22 /nova/objectstore ###
不关心，基于本地文件实现S3式的存储服务，用于兼容Amazon EC2的存储接口。

### 4.3.23 /nova/test ###
各种test。

## 4.4 数据库表 ##
- compute_nodes：计算节点信息
- consoles
- block_device_mapping:实例所在的磁盘分区信息
- fixed_ips:固定ip表，虚机实例的ip地址就是从这张表获取
- floating_ips:
- instance_actions:实例的所有操作都会在这张表中记录，包括create.delete.stop等操作。
- instance_action_events:实例操作的事件
- instance_faults:实例错误信息
- instance_metadata：为实例增加的元数据会记录在这张表中
- instance_types:就是flavorlist的信息
- instances:记录所有实例信息的表，删除的实例信息也会存储在这张表里面。
- key_pairs:记录key值信息的表
- migrations:将实例移到了可执行的主机的信息
- networks:网络信息
- s3_images:
- security_groups:记录安全组信息表
- security_group_instance_association：
- security_group_rules：安全组规则表
- services：记录服务的信息。有compute，networks等
