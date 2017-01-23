```
Nova相关资料整理
1	概念篇	6
1.1	部署	6
1.2	监控	8
2	架构篇	9
2.1	系统架构	9
2.2	Nova组件构成	9
2.2.1	API Server (nova-api)	9
2.2.2	Message Queue (rabbit-mq server)	9
2.2.3	Compute Workers (nova-compute)	10
2.2.4	Network Controller (nova-network)	10
2.2.5	Volume Worker (nova-volume)	10
2.2.6	Scheduler (nova-scheduler)	10
2.3	Nova部署图	11
2.4	Nova对外提供功能以及周边依赖	12
2.5	Nova逻辑视图	12
2.6	Nova-api启动流程图	13
2.7	Nova-api处理请求流程	13
3	基础知识篇	15
3.1	RabbitMQ	15
3.1.1	F版本中rabbitmq的应用	15
3.1.2	G版本中rabbitmq的应用	15
3.1.3	rabbitmq基本介绍	16
1)	基本概念	16
2)	Exchange类型	18
3)	可靠性因素	19
4)	性能因素	20
3.1.4	官方文档上的那由浅及深的六个例子	20
3.1.5	Nova服务使用rabbitmq介绍	29
3.1.6	Rabbitmq问题定位	35
3.2	WSGI标准	37
3.2.1	简介	37
3.2.2	基本原理与目标	37
3.2.3	概述	38
3.2.4	应用程序接口	39
3.2.5	服务器接口	41
3.2.6	中间件:同时扮演两种角色的组件	44
3.2.7	详细说明	47
3.2.8	environ 变量	49
3.2.9	输入和错误流	52
3.3	WebOb	54
3.4	Nova存储管理	65
3.5	Nova中的调度Scheduler	69
3.7.1	简单逻辑图	69
3.7.2	默认支持的调度过滤器	70
3.7.3	端到端调度流程图	72
3.6	虚拟机配额和过滤器	72
3.7	文件注入和metadata机制	76
3.9.1	什么是metadata机制？	76
3.9.2	什么是文件注入？	76
3.9.3	注入文件和metadata机制，会不会有冲突？	77
3.9.4	文件注入的机制	81
3.9.5	注入文件失败了，会发生什么？	82
3.9.6	后端卷VM，是否支持文件注入呢？	82
3.9.7	Metadata和Quantum侧配置	83
3.9.8	metadata机制是否生效？	84
3.9.9	metadata的实现机制	86
3.8	Nova 中的db archiving	96
4	实现篇	99
4.1	虚拟机创建	99
4.1.1	创建虚拟机的逻辑流程	99
4.1.2	API创建虚拟机的端到端流程	100
4.2	虚拟机启动流程分析	101
4.2.1	整体流程	101
4.2.2	API	101
4.2.3	Controller	102
4.2.4	Scheduler	103
4.2.5	Compute worker	104
a)	Network Controller	105
b)	使能dhcp	106
c)	为网络分配vlan	106
d)	为instance分配mac地址	107
4.3	虚拟机迁移	107
4.4	KeyStone认证管理	117
4.5	Scheduler filter机制	118
4.5.1	filters	118
4.5.2	抽象	118
4.5.3	filters管理	119
4.5.4	代码	120
4.6	Nova服务启动流程分析	121
4.7	Nova资源周期上报流程分析	131
4.8	Nova对web路由的初始化	137
4.9	创建vm过程中libvirt对image相关处理分析	143
4.9.1	概述	143
4.9.2	处理流程	143
4.9.3	代码走读	144
5	问题定位	153
5.1	冷迁移VM 问题定位报告	153
5.2	虚拟机VNC拒绝连接问题定位	155
5.3	VNC时断时续 定位报告	157
5.3.1	问题现象	157
5.3.2	VNC使用原理	157
5.3.3	问题定位	158
5.3.4	定位结论	158
6	拓展篇	159
6.1	FusionCompute/Nova+扩展原则和思路	159
7	其它	161
7.1	Nova虚拟机状态	161
7.1.1	Nova虚拟机状态简介	161
7.1.2	power_state	161
7.1.3	vm_state	162
7.1.4	task_state	164
7.2	Nova定时任务	165
7.3	API	170
7.3.1	Nova-manage	170
7.3.2	Euca2tools	174
7.3.3	OpenStack APIs	176
7.3.4	Libvirt服务列表	182

1 概念篇
　　支持OpenStack云中实例（instances）生命周期的所有活动都由Nova处理。这样使得Nova成为一个负责管理计算资源、网络、所需可扩展性的平台。但是，Nova自身并没有提供任何虚拟化能力，相反它使用libvirt API来与被支持的Hypervisors交互。Nova 通过一个与Amazon Web Services（AWS）EC2 API兼容的web services API来对外提供服务。
　　一个虚拟机群集管理组件（不考虑Baremetal，其实他也可以管理物理机），管理虚拟机的创建停止等生命周期全过程，制定虚拟机的分配策略（虚拟机如何选择要运行的物理机），进行虚拟机的迁移等等。功能和特点：
■实例生命周期管理
■管理计算
■REST风格的API
■异步的一致性通信
■Hypervisor透明：支持Xen,XenServer/XCP, KVM, UML, VMware vSphere and Hyper-V
　　在Grizzly版的Nova中，取消了nova-compute的直接数据库访问。大概两个原因：
1) 安全考虑。因为compute节点通常会运行不可信的用户负载，一旦服务被攻击或用户虚拟机的流量溢出，则数据库会面临直接暴露的风险
2) 方便升级。将nova-compute与数据库解耦的同时，也会与模式（schema）解耦，因此就不会担心旧的代码访问新的数据库模式。
　　目前，nova-conductor暴露的方法主要是数据库访问，但后续从nova-compute移植更多的功能，让nova-compute看起来更像一个没有大脑的干活者，而nova-conductor则会实现一些复杂而耗时的任务，比如migration（迁移）或者resize（修改虚拟机规格）
1.1 部署
　　nova-conductor是在nova-compute之上的新的服务层。应该避免nova-conductor与nova-compute部署在同一个计算节点，否则移除直接数据库访问就没有任何意义了。同其他nova服务（nova-api, nova-scheduler）一样，nova-conductor也可水平扩展，即可以在不同的物理机上运行多个nova-conductor实例。
　　经典的部署方式中（一个controller节点，多个compute节点），可以将nova-conductor运行在Controller节点
　　
　　这也就意味着Controller节点将比以前运行更多的任务，负载变重，因此有必要对负载做监控，必要时需要扩展contorller服务。比如当在多个节点运行nova-api时，就需要在前端做负载均衡；多个节点运行nova-scheduler或nova-conductor时，负载均衡的任务就由消息队列服务器完成； 
　　
1.2 监控
　　需要对nova-conductor进行性能监控以便决定是否对服务进行扩展。首先可以监控所在节点的CPU负载；其次可以监控消息队列中的消息个数及大小（对于Qpid： qpid-stat，对于RabbitMQ: rabbitmqctl list_queues）

2 架构篇
2.1 系统架构
     下图是Nova的软件架构，每个nova-xxx组件是由python代码编写的守护进程，每个进程之间通过队列（Queue）和数据库（nova database）来交换信息，执行各种请求。而用户通过nova-api暴露的web service来同其他组件进行进行交互。Glance是相对独立的基础架构，nova通过glance-api来和它交互。
　　
2.2 Nova组件构成
2.2.1 API Server (nova-api)
     API Server对外提供一个与云基础设施交互的接口，也是外部可用于管理基础设施的唯一组件。管理使用EC2 API通过web services调用实现。然后API Server通过消息队列（Message Queue）轮流与云基础设施的相关组件通信。作为EC2 API的另外一种选择，OpenStack也提供一个内部使用的“OpenStack API”。
2.2.2 Message Queue (rabbit-mq server)
     OpenStack 节点之间通过消息队列使用AMQP（Advanced Message Queue Protocol）完成通信。Nova 通过异步调用请求响应，使用回调函数在收到响应时触发。因为使用了异步通信，不会有用户长时间卡在等待状态。这是有效的，因为许多API调用预期的行为都非常耗时，例如加载一个实例，或者上传一个镜像。
     AMQP，即Advanced Message Queuing Protocol，高级消息队列协议，是应用层协议的一个开放标准，为面向消息的中间件设计。AMQP的主要特征是：
（1） 面向消息、队列、路由（包括点对点和发布/订阅）、可靠性、安全。
（2） AMQP在消息提供者和客户端的行为进行了强制规定，使得不同卖商之间真正实现了互操作能力。
（3） AMQP是一个协议，而RabbitMQ是对这个协议的一个实现。
     Rabbit MQ一个独立的开源实现，服务器端用Erlang语言编写，支持多种客户端，如：Python、Ruby、.NET、Java、JMS、C、PHP、ActionScript、XMPP、STOMP等，支持AJAX。RabbitMQ发布在Ubuntu、FreeBSD平台。
     Kombu是一个AMQP(Advanced Message Queuing Protocol)消息框架。所谓框架，就是一个软件的半成品，是为了提高开发效率而开发的。Kombu对RabbitMQ提供的API进行了封装，使得程序更加面向对象化，比如封装出了Exchange, Queue等这些类，使得对RabbitMQ的操作更加简单，同时，功能更加强悍。在nova支持好几种这样的框架，可以通过配置文件来配置使用哪种框架，默认的就是使用Kombu 。
2.2.3 Compute Workers (nova-compute)
     Compute Worker处理管理实例生命周期。他们通过Message Queue接收实例生命周期管理的请求，并承担操作工作。在一个典型生产环境的云部署中有一些compute workers。一个实例部署在哪个可用的compute worker上取决于调度算法。
2.2.4 Network Controller (nova-network)
     Network Controller 处理主机地网络配置。它包括IP地址分配、为项目配置VLAN、实现安全组、配置计算节点网络。
2.2.5 Volume Worker (nova-volume)
```
