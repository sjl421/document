# OpenStack概况 #
## OpenStack的组件 ##
| Service | Project name | Description |
| --------| ------------ | ----------- |
| Dashboard | 	Horizon | 提供了一个基于Web的自助服务门户与底层OpenStack服务进行交互。用于管理各种资源，例如：云主机，网络，存储，用户身份等。 |
| Compute | Nova | 提供管理虚拟机的生命周期服务，包括创建虚拟机，调度虚拟机和销毁虚拟机. |
| Networking | 	Neutron | 提供网络服务，用户通过API定义网络，支持比较流行的网络技术。 |
| Storage | 
| Object Storage | Swift | 提供对象存储服务。 |
| Block Storage | 	Cinder | 提供块存储服务。 |
| Shared services |
| Identity service | Keystone | 提供身份认证服务。 |
| Image service | Glance | 镜像存储服务。 |
| Telemetry | Ceilometer | 监控和统计OpenStack资源利用情况。 |
| Higher-level services | 
| Orchestration | Heat | |
## 对OpenStack的理解 ##
OpenStack是云的一个框架，有许多组件构成，各组件是一个独立的项目。各组件独立运行在物理节点上，通过RESTful API交互构成一个大的资源池。每个组件提供不同的服务，完成不同的功能，其中包括：计算服务，网络服务，存储服务等。
各组件之间都是松耦合的，换句话说，就是各组件都是可以被能够完成相同功能的其他组件和项目所替换。例如，OpenStack官方文档中安装OpenStack的例子使用的是MySQL数据库，同时，文档中也提到可以通过PostgreSQL替换MySQL，可以使用你所熟悉的任何一种数据库。OpenStack的架构遵循热插拔的模式，并不是任何一个组件是不可替代的。OpenStack之所以这样做，一方面OpenStack是开源的，另一方面OpenStack的发展不希望被一个闭源的组件所束缚。
