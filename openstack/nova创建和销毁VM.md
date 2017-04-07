## 创建Instance流程
### 调用主要函数和类
    ===》 Request --->创建instance请求
    ===》 ComputeManager --->封装了创建，启动，重启，关闭，终止instance等方法
    ===》 build_and_run_instance --->接受到请求后，执行创建instance的方法
    ===》 _do_build_and_run_instance --->保存instance的状态，做一些初始化工作
    ===》 _build_and_run_instance --->准备创建instance的资源，包括网络，硬盘，镜像等
    ===》 driver --->具体的底层虚拟化接口，包括libvirt，vmwareapi，xenapi等
    ===》 spawn --->创建instance的操作，传递到具体的虚拟化驱动上执行
    ===》 _get_guest_xml --->根据instance具体的配置，生成xml
    ===》 _create_domain_and_network --->在具体的虚拟化基础上，准备instance和网络
    ===》 _create_domain ---> 创建instance
    ===》 libvirt_guest.Guest --->客户机对象，包含对客户机的所有操作
    ===》 create --->调用客户机对象中的create方法创建instance
    ===》 Host --->具体创建instance的node节点，包含对node的所有操作
    ===》 write_instance_config --->向具体的node中写入instance的xml配置文件
    ===》 get_connection --->获取具体node的连接对象
    ===》 defineXML --->获取具体的node连接后，向连接中写入xml文件由具体的虚拟化创建instance
    
## 销毁Instance流程
### 调用主要函数和类
    ===》 Request --->终止instance请求
    ===》 terminate_instance --->接受终止instance的函数
    ===》 do_terminate_instance --->执行终止instance
    ===》 _delete_instance --->更新容量，删除instance
    ===》 _shutdown_instance --->获取instance硬盘信息，关闭instance
    ===》 driver --->具体的底层虚拟化接口，包括libvirt，vmwareapi，xenapi等
    ===》 destroy --->调用虚拟化的方法，销毁instance
    ===》 _destroy --->具体执行销毁动作
    ===》 Host --->具体instance的node节点，包括对instance的所有操作
    ===》 get_guest --->从Host中获取将要销毁的instance对象
    ===》 Guest --->客户机对象
    ===》 poweroff --->调用客户机对象的方法
    ===》 destroy ---->向具体的instance所在的node发送销毁指令，终止instance
    
