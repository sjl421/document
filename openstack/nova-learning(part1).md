# 1.逻辑架构 #
nova是IaaS系统的主要部门，旨在为大规模的配置和管理虚拟机实例提供一个框架。
它允许用户使用自己的镜像文件，通过可编程API创建，管理和销毁虚拟服务器。nova自身并没有提供任何虚拟化的能力，相反它使用libvirt，API等来与被支持的Hypervisors交互
它包含下面很多组件：
## 1.1 nova-api ##
nova-api是整个nova的入口，它接收和响应用户操作虚拟机和云硬盘的请求，将请求发送至消息队列（Queue），由相应的服务（nova-scheduler等）执行相关的操作。
nova-api处理用户请求并将之路由（WSGI，Web Service Gateway Interface）给各个云控制器。
云控制器（Cloud Controller）：nova-api的一个类，负责处理nova-computer，nova-network，nova-api和nova-scheduler之间的通讯，是nova-api内的一个类。例如：/nova/api/openstack/compute/servers.py中的class ServersController（wsgi.Controller）
## 1.2 nova-computer ##
nova-computer是主要的执行守护进程，nova-computer运行在每一个计算节点上负责与hypervisor通讯，nova-computer整合了计算资源CPU，存储，网络三类资源部署管理虚拟机，实现计算能力的交付。包括如下内容：
- 运行虚拟机
- 终止虚拟机
- 重启虚拟机
- 挂载虚拟机
- 挂载云硬盘
- 卸载云硬盘
- 控制台输出

nova-computer处理管理实例生命周期，nova-computer通过Queue接收实例生命周期管理的请求，并承担操作工作。一个实例部署在哪个可用的nova-computer上取决算法（nova-scheduler）。
nova-computer有两个工作：
- 接收Queue中的请求并执行，如部署虚拟机
- 维护数据库相关模型的状态数控

## 1.3 nova-network ##
nova-network的职责是实现网络资源池的管理，包括IP池，网桥接口，VLAN，防火墙的管理，配置计算节点网络。nova-network接收Queue中请求并执行。*已被neutron取代*

## 1.4 nova-scheduler ##
nova-scheduler的职责是调度实例部署在哪个计算节点上，接收Queue中请求并执行。
nova-scheduler通过恰当的调度算法从可用资源池获得一个nova-computer。Scheduler会根据诸如负载，内存，可用域的物理距离，CPU架构等作出调度决定。nova-scheduler负责在资源池中选择最合适的计算节点来负责运行新的实例（同时它也负责获取卷）。
当前nova-scheduler实现了一些基本的调度算法：
- 随机算法：计算主机在所有可用域内随机选择
- 可用域算法：跟随机算法相仿，但是计算主机在指定的可用域内随机选择
- 简单算法：这种方法选择负载最小的主机运行实例。负载信息可通过负载均衡器获得

## 1.5 nova-volume ##
nova-volume的职责是创建，挂载和卸载持久化的磁盘虚拟机。volume的职责包括如下：
- 创建云硬盘
- 删除云硬盘
- 弹性计算硬盘

一句话：就是为实例增加块设备存储。*已经被Cinder取代*

## 1.6 Queue ##
Queue也就是消息队列，nova各个服务之间的通讯几乎都是靠它进行的。当前的Queue是用RabbitMQ实现的，它和database一起为各个守护进程之间传递消息。
通过AMQP协议（Advanced Message Queue protocol），即高级消息队列协议来通信。为了避免在等待响应的时候造成每个组件阻塞，OpenStack Compute使用了异步调用，当响应被接收时候会触发回调。
nova的各个服务是以数据库和队列为中心进行通信的：

## 1.7 Database ##
存储云基础架构中的绝大多数状态。这包括了可用的实例类型，在用的实例，可用的网络和项目。当前广泛使用的数据库是sqllite3（仅适用于测试和开发工作），MySQL和PostgreSQL。

## 1.8 nova-conductor ##
后面版本提出来的服务，在此之前，nova-compute都是直接访问数据库，一旦其被攻击，则数据库会面临直接暴露的风险，出于安全考虑，应该避免nova-conductor与nova-compute部署在同一台服务器上。
nova-conductor的加入也使得nova-compute与数据库解耦，因此数据库schema升级的同时不需要也去升级nova-compute。
nova-conductor功能如下：
- 耗时较长的TaskAPI处理，nova-api将请求发给nova-conductor就返回了，之后操作由nova-conductor来做。这时候nova-list，nova show可以看到VM_State是Building。
- API显示修改数据库的数据入口，如实例的规格修改：nova resize。不希望有显示接口能够通过nova-compute服务提供的API修改数据库数据。
- 其他服务依赖。如nova-compute需要依赖nova-conductor启动成功后才能启动成功。
- 其他服务的心跳定时写入。nova-compute，nova-conductor，nova-scheduler，nova-console，nova-consoleauth。

# 2.配置模式 #
nova平台中有两类节点：
- 控制节点：提供nova-network，nova-scheduler，nova-api，nova-volume，Database，身份管理和镜像管理等服务。
- 计算节点：主要提供nova-compute服务。

其角色由安装的nova服务决定。

模块 | 功能 | 一般部署位置
---- | -------|------------
nova-api | 接收rest消息 | 控制节点
nova-scheduler | 选择合适的主机 | 控制节点
nova-conductor | 数据库操作和复制流程控制 | 控制节点
nova-compute | 虚拟机生命周期管理和资源管理 | 计算节点
nova-novncproxy | novnc访问虚拟机代理 | 控制节点
nova-consoleauth | novnc访问虚拟机鉴权 | 控制节点
节点之间使用AMQP作为通讯总线，只要将AMQP消息写入特定的消息队列中，相关的服务就可以获取该消息进行处理。由于使用了消息总线，因此服务之间的位置透明的，你可以将所有的服务部署在同一台主机上，也可以根据业务需要，将其分开部署在不同的主机上。
用于生产环境的nova平台配置一般有以下三种类型：

## 2.1最简配置 ##
需要至少两个节点，除了nova-compute外所有服务都部署在一台主机里，这台主机进行各种控制管理，即控制节点。

## 2.2标准配置 ##
控制节点的服务可以分开在多个节点，标准的生产环境推荐使用至少4台主机来进一步细化职责。nova-api，nova-network，nova-volume和nova-compute服务分别由一台主机担任。

## 2.3 高级配置 ##
很多情况下（比如为了高可用性），需要把各种管理服务分别部署在不同的主机（比如分别提供数据库集群服务，消息队列，镜像管理，网络控制等），形成更复杂的架构：

# 3.基本概念 #
## 3.1 WSGI & Paste Deploy等 ##
WSGI相当于是WEB服务器和Python应用程序之间的桥梁。
[http://www.infoq.com/cn/articles/OpenStack-UnitedStack-API1?utm_campaign=infoq_content&utm_source=infoq&utm_medium=feed&utm_term=%E4%BA%91%E8%AE%A1%E7%AE%97](http://www.infoq.com/cn/articles/OpenStack-UnitedStack-API1?utm_campaign=infoq_content&utm_source=infoq&utm_medium=feed&utm_term=%E4%BA%91%E8%AE%A1%E7%AE%97)
[http://segmentfault.com/a/1190000003069785](http://segmentfault.com/a/1190000003069785)
- novaclient将用户命令转化成标准的HTTP请求
- Paste Deploy将请求路由到具体的WSGI Application

nova-api启动，根据/etc/nova.conf里面的enable_apis选项内容创建一个或多个WSGI Server，我们启动的是osapi_compute
Paste Deploy会在osapi_compute这个WSGI Server创建时参与进来。基于/etc/nova/api-paste.ini这个Paste配置文件去加载WSGI Server。/nova/cmd/api.py创建server = service.WSGIService(), /nova/service.py中class WSGIServer.__init__()从Paste配置文件去加载API对应的WSGI Application。从[composite:osapi_compute]开始加载，use表示分发器，根据下面不同的key进行分发，如v2.1:和keystone = 。
- Routes将请求路由到具体函数并执行

从Paste配置文件最后加载的paste.app_factory = nova.api.openstack.compute: APIRouterV21.factory开始，class API RouterV21基类nova.api.openstack.
APIRouterV21.__init__()使用stevedore的EnabledExtensionManager类载入位于/nova/setup.cfg中命名空间'nova.api.v21.extensions'下的所有资源，每个资源都会被封装成一个nova.api.openstack.wsgi.Resource对象，分别对应一个WSGI application，并建立路由规则，这样便可以根据url的“GET /v2.1/servers/details”红色部分路由到正确的WSGI应用，即资源上。
每个资源会在自己的__call__()方法中，根据HTTP请求的url的“GET /v2.1/servers/details”红色部分其路由到对应Controller上的detail()方法。

## 3.2 Evenlet ##
[http://blog.csdn.net/hackerain/article/details/7836993](http://blog.csdn.net/hackerain/article/details/7836993)
[http://www.choudan.net/2013/08/18/OpenStack-eventlet%E5%88%86%E6%9E%90(%E4%B8%80).html](http://www.choudan.net/2013/08/18/OpenStack-eventlet%E5%88%86%E6%9E%90(%E4%B8%80).html)

## 3.2 Oslo.config ##
[http://www.choudan.net/2013/11/27/OpenStack-Oslo.config-%E5%AD%A6%E4%B9%A0(%E4%B8%80).html](http://www.choudan.net/2013/11/27/OpenStack-Oslo.config-%E5%AD%A6%E4%B9%A0(%E4%B8%80).html)
[http://www.choudan.net/2013/11/28/OpenStack-Oslo.config-%E5%AD%A6%E4%B9%A0(%E4%BA%8C).html](http://www.choudan.net/2013/11/28/OpenStack-Oslo.config-%E5%AD%A6%E4%B9%A0(%E4%BA%8C).html)
