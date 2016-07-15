# Nova Service #
Nova组件在OpenStack中主要提供计算服务，换句话说，就是管理虚拟机的生命周期，创建虚拟机，停止虚拟机，销毁虚拟机和回收资源。
## Nova模块 ##
* nova-api

    接受和响应用户对计算资源的的API调用。支持OpenStack Comput API，Amazon EC2 API。
* nova-api-metadata

    接受虚拟机元数据请求
* nova-compute

    运行一个守护进程通过hypervisor APIs管理虚拟机的生命周期，例如：
    * XenAPI for XenServer/XCP
    * libvirt for KVM or QEMU
    * VMwareAPI for VMware


* nova-scheduler

    负责虚拟机的调度服务，通过一些算法和策略选择合适的主机启动虚拟机。
* nova-conductor

    提供与数据库的交互服务
* nova-cert

    提供nova证书服务
* nova-network

    提供nova网络服务，nova最早通过该服务提供网络，在后面版本中从nova分离出来产生Neutron服务，nova-network主要特点是网络拓扑简单，提供二层网络。Neutron网络拓扑更复杂，支持流行的网络拓扑。
* nova-consoleauth

    token身份认证的服务
* nova-novncproxy

    vnc登录虚拟机的服务，Supports browser-based novnc clients.
* nova-spicehtml5proxy

    SPICE登录虚拟机，Supports browser-based HTML5 client.
* nova-xvpvncproxy
    vnc登录虚拟机，Supports an OpenStack-specific Java client.
* nova-cert

    x509证书
* nova

    nova客户端，支持命令行
    
## Nova创建虚拟机流程 ##

user ---> nova-api ---> nova-conductor ---> nova-scheduler ---> nova-compute ---> virt-driver ---> neutron ---> cinder
