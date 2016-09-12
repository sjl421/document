# 1. nova network简介 #
网络管理和配置是云计算中一项非常重要的功能。nova自带的nova-network实现了一些基本的网络模型，允许虚拟机之间的相互通信及虚拟机对internet的访问。归纳的来讲nova network的主要功能有：
- 网络模型：nova network实现了三种网络模型，允许管理员根据自己的需要进行组网，让虚拟机之间可以相互通信。这三种模式分别是：flat、flatdhcp、vlan，后面会对这三种模型进行更加详细的介绍。
- IP地址管理：nova network需要管理虚拟机使用的IP地址，这些地址包含两类，一类是fixed ip，在虚拟机的整个生命周期中该IP地址都不会发生变化；另一类是floating ip，是动态的分配给虚拟机的，随时都可以收回。
- dhcp功能：在flatdhcp和vlan模式下，虚拟机是通过DHCP来获取其fixed ip的；nova network会启动dnsmasq作为虚拟机的DHCP服务器，该虚拟机分配ip。
- 安全防护：出于安全的考虑，nova中的虚拟机可以防止IP/MAC洪泛，不能随便修改虚拟机的MAC地址，修改后虚拟机就不能上网了，这项功能主要是通过ebtables/iptables实现的。

下面简单的介绍下nova network的三种网络模型。
- 在这三种模型中flat是最简单的，nova的操作也最少，相关的配置需要管理员事先配置好。在flat模式下，管理员需要手动创建一个网桥，所有的虚拟机都会关联到该网桥，所有的虚拟机也都处于同一个子网下，虚拟机的fixed ip都是从该子网分配，而且网络相关的配置信息会在虚拟机启动时注入到虚拟机镜像中。
- flatdhcp模式与flat比较接近，但nova会自动创建网桥，维护已经分配的floating ip，并启动dnsmasq来配置虚拟机的fixed ip，创建虚拟机时，nova会给虚拟机分配一个fixed ip，并将MAC/IP的对应关系写入dnsmasq的配置文件中，虚拟机启动时通过DHCP获取其fixed ip，因此就不需要将网络配置信息注入到虚拟机中了。
- vlan模式比上面两种模式复杂，每个project都会分配一个vlan id，每个project也可以有自己的独立的ip地址段，属于不同project的虚拟机连接到不同的网桥上，因此不同的project之间是隔离的，不会相互影响。为了访问一个project的所有虚拟机需要创建一个vpn虚拟机，以此虚拟机作为跳板去访问该project的其他虚拟机。与flatdhcp类似，vlan模式下，也会为每个project启动一个dnsmasq来配置虚拟机的fixed ip。
# 2. nova network部署与配置 #
部署nova network时至少需要两块网卡，一块作为public network，主要承载公网流量和openstack各个组建之间的流量，要能够访问公网，ip地址可以为内网地址也可以为公网地址；另一块作为internal network，承载虚拟机之间相互通信的流量，不需要为其分配ip地址，只需要保证它们物理上可以互联即可。
nova network有两种常见的部署方式，第一种方式是单个nova-network节点，充当所有虚拟机的网关，并维护dhcp服务器。这种方式最大的问题就是单点故障，一旦nova-network节点出问题了，就会影响到所有的虚拟机，需要实施HA方案。另一种方式就是multihost，即在每个计算节点上部署nova-network，每个计算节点上的虚拟机通过本机的nova-network就可以获取ip地址、metadata及访问公网。这样做的优势就是一旦某个节点出现问题，也不会影响到其他节点，而且有很好的扩展性，也是我们目前部署最为广泛一种模式。
nova network的主要配置选项有：

- network_manager：该选项决定了网络的模式，有三种可选的：nova.network.manager.FlatManager、nova.network.manager.VlanManager、nova.network.manager.FlatDHCPManager，分别对应上面所提到的flat模式、flatdhcp模式和vlan模式。
- fixed_range：所有虚拟机fixed ip所在的网段，通过nova-manage创建网络时，创建的网络应该是该网段的子网。
- floating_range：所有可以的floating ip所在的网段。
- force_dhcp_release：是否在删除虚拟机时立即释放其所占用的ip地址。若为True，则会立即释放，否则需要经过一段时间才释放。默认应该设置为True。
- my_ip：nova-network所在的ip地址，不显式设置时该ip是宿主机上一个能访问公网的ip地址。配置时可显式的设置为本机的公网ip。
- multi_host：是否启用multihost模式，如果启用，则在每个计算节点上至少要启动nova-api-metadata、nova-network、nova-compute三个服务。默认值为false。启用multihost时，需要将其设置为True。
- public_interface：公网的物理接口。nova network会将floating ip配置在该接口上，另外就是在做SNAT时会将其作为参数加入到iptables规则中。
- flat_network_bridge：在flat/flatdhcp模式下，使用那个网桥来连接虚拟机，实现虚拟机之间的通信。
- flat_interface：虚拟机之间通信的物理接口。在flatdhcp模式下，nova network会将该接口加入到flat_network_bridge中，实现跨宿主机的虚拟机之间的通信。默认为none。
- vlan_interface：虚拟机之间通信的物理接口。在vlan模式下，每个project会有一个vlan，不同的vlan和不同的网桥关联，网桥再通过vlan_interface实现跨宿主机的通信。
- vlan_start：在vlan模式下，最小的vlan id。
# 3. 典型环境配置 #
## 1. all in one ##
all in one环境下，每台机器上有一整套的openstack环境，每台都可以作为一个region，对于测试多region非常有必要。在all in one环境下，虚拟机之间的网络通信通过网桥就可以完成，所有出到公网的流量则是通过SNAT来实现。所以在这种环境下，需要指定public_interface、flat_network_bridge，但不需要指定flat_interface，要让其保持默认的none，否则不同的all in one环境可能会出现相互干扰。上次demo环境的网络问题就是因为flat_interface配置不当造成的。另外，在通过nova-manage创建网络时也需要注意，不要指定bridge_interface，否则bridge_interface会被加入到网桥中，可能会造成一些很奇怪的问题。上次demo环境中，每隔一段时间配置在eth0上的ip公网ip地址会被移动到网桥上，而且eth0也会被加入到网桥上，其原因就是因为在创建网络时将bridge_interface设置为了eth0.
## 2. multihost ##
在multihost模式下，首先需要将multi_host设置为True，然后在每个计算节点上都安装好nova-network nova-api-metadata nova-compute。
参考资料
1. http://docs.openstack.org/folsom/openstack-compute/admin/content/ch_networking.html
2. http://www.mirantis.com/blog/openstack-networking-single-host-flatdhcpmanager/
