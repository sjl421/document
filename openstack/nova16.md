```
4.4 KeyStone认证管理

4.5 Scheduler filter机制
4.5.1 filters
　　根据不同的需求，有很多种类型的过滤方式，于是就有很多的filter，我们把这些filter类文件放置在同一个package中管理。当然，这些filter我们不可能全部用到，于是我们需要为管理员提供一种方式告诉系统他需要哪些filter，我们可以用配置文件实现。此外，我们需要两个额外的功能：
　　1. 我们想知道package中所有的filter类
　　2. 因为管理员可能因为疏忽大意，在配置文件中填写了错误的类（比如把过滤主机的filter填写成了其他功能的filter，因为系统中会有很多种filter，管理员也会晕头转向），对于这些错误的配置，我们需要识别，也就是所谓的容错
4.5.2 抽象
　　为了完成上面两个目标，我们需要一些前提。
　　首先，根据面向对象的原则，具有相同特征或行为的东西，需要将他们进行抽象。对于filter而言，其作用就是过滤，因此需要有一个表示过滤的基类BaseFilter。其次，过滤根据用途也分很多种，比如主机的过滤，虚拟机的过滤等等，而对于每一种过滤又有很多方法，所以某一个用途的filter也需要抽象，比如我们有BaseHostFilter表示主机过滤，它继承自BaseFilter。最后，当然是各种主机过滤的不同实现，比如基于ram的过滤，基于vcpu的过滤等等。它们的关系图如下：
因此，对于任何一种filter，我们只需调用其filter_all()方法，就能获得过滤后的结果。
4.5.3 filters管理
　　现在我们有了一些filter类，每个filter类分别位于单独的文件中，我们将这些文件放置在一个package中。当然，我们可能有另外一个包package2，里面是另一个功能的filters，于是我们会想到要提供一种统一的方式对这些package进行管理。
　　同样是面向对象的原理，我们需要一个统一的类管理这种类型的package，而不用关心每个package里到底是哪种filter（我们只知道每个package中的filters都是同一类型，即继承自同一个BaseXXXFilter，进而继承自BaseFilter）。于是，利用python的语言特性，我们可以很快的写出这样的处理类，参见nova/loadables.py中BaseLoader类的实现：

　　有了基类自然就有实现类。注意BaseLoader类中有一个loadable_cls_type属性，不同的实现类需要传递不同参数。比如我们有HostFilterHandler类用来管理主机过滤包中的filter类，那么就需要初始化时传递BaseHostFilter(还记得刚才的类继承图么？)。
　　当然，不要忘了过滤的目的，我们最好在BaseLoader类中提供一个方法get_filtered_objects(filters, objs)，调用该方法完成过滤的功能。在OpenStack中，该方法是在一个继承自BaseLoader类，同时又被HostFilterHandler类继承的类(BaseFilterHandler)中实现。即：
　　
4.5.4 代码
　　以创建虚拟机调度为例，在nova-scheduler中有HostManager类，其功能主要是管理主机，当然也包括对主机进行过滤。在其初始化函数中有以下两句：
其中：
1. HostFilterHandler：filter管理类，位于nova/scheduler/filters/__init__.py，而nova/scheduler/filters/路径下就是主机过滤的类文件，它的初始化可以验证上面的理论。
2. 配置项scheduler_available_filters：
表示管理员希望使用哪些filters。为了容错，我们调用get_matching_classes方法来排除因管理员疏忽而填错的类。
　　在HostManager类的get_filtered_hosts方法中完成对主机的过滤：
　　即：对hosts表示的每一个主机，调用filter_classes表示的每个filter处理，返回通过的hosts。
　　具体的过滤方式是：
　　假如管理员配置了filter1, filter2, filter3，有三个主机host1, host2, host3。于是按照filter的顺序，假如host1和host3通过了filter1，那么调用filter2时，只考虑host1和host3。假如只有host1通过了filter2，则调用filter3时，仅考虑host1。

4.6 Nova服务启动流程分析
Nova的服务类型分为两种，WsgiService和RpcService，每一种服务类型都会根据nova.conf的配置启动一个或者多个进程。
先来讲一下Nova进程的启动过程，以内部git服务器上的最新代码为例：
/nova/bin/目录下为所有的启动脚本入口
以RpcService nova-scheduler为例：
1) /nova/bin/nova-scheduler会调用/nova/nova/cmd/schudler.py的main方法
from nova.cmd import scheduler
scheduler.main()
2) scheduler.py的main方法，会创建一个RpcService，并将AMPQ的topic传入create方法，作为参数
def main():
    config.parse_args(sys.argv)
    logging.setup("nova")
    utils.monkey_patch()
    server = service.service.create(binary='nova-scheduler',
                                    topic=conf.scheduler_topic)
    service.serve(server)
    service.wait()
3) 我们来看一下nova.service.Service.create方法都做了什么事
首先根据binary参数的后半部分 nova-scheduler和_manager拼接作为key [scheduler_manager] 从nova.conf中取对应的实现类，默认值为 nova.scheduler.manager.SchedulerManager，然后将这些作为参数调用Service的__init__方法，生成Service实例
    @CLASSMETHOD
    def create(cls, host=none, binary=none, topic=none, manager=none,
               report_interval=none, periodic_enable=none,
               periodic_fuzzy_delay=none, periodic_interval_max=none,
               db_allowed=true):
        if not host:
            host = conf.host
        if not binary:
            binary = os.path.basename(sys.argv[0])
        if not topic:
            topic = binary.rpartition('nova-')[2]
        if not manager:
            manager_cls = ('%s_manager' %
                           binary.rpartition('nova-')[2])
            manager = conf.get(manager_cls, none)
        if report_interval is none:
            report_interval = conf.report_interval
        if periodic_enable is none:
            periodic_enable = conf.periodic_enable
        if periodic_fuzzy_delay is none:
            periodic_fuzzy_delay = conf.periodic_fuzzy_delay
        service_obj = cls(host, binary, topic, manager,
                          report_interval=report_interval,
                          periodic_enable=periodic_enable,
                          periodic_fuzzy_delay=periodic_fuzzy_delay,
                          periodic_interval_max=periodic_interval_max,
                          db_allowed=db_allowed)
        return service_obj

4) 在Service的__init__方法中根据scheduler_manager的值，import scheduler_manager class并实例化manager
def __init__(self, host, binary, topic, manager, report_interval=none,
                 periodic_enable=none, periodic_fuzzy_delay=none,
                 periodic_interval_max=none, db_allowed=true,
                 *args, **kwargs):
        super(service, self).__init__()
        self.host = host
        self.binary = binary
        self.topic = topic
        self.manager_class_name = manager
        self.servicegroup_api = servicegroup.api(db_allowed=db_allowed)
        manager_class = importutils.import_class(self.manager_class_name)
        self.manager = manager_class(host=self.host, *args, **kwargs)
        self.report_interval = report_interval
        self.periodic_enable = periodic_enable
        self.periodic_fuzzy_delay = periodic_fuzzy_delay
        self.periodic_interval_max = periodic_interval_max
        self.saved_args, self.saved_kwargs = args, kwargs
        self.backdoor_port = none
        self.conductor_api = conductor.api(use_local=db_allowed)
        self.conductor_api.wait_until_ready(context.get_admin_context())
5) 我们再看service.serve(server)都做了什么
def main():
    config.parse_args(sys.argv)
    logging.setup("nova")
    utils.monkey_patch()
    server = service.service.create(binary='nova-scheduler',
                                    topic=conf.scheduler_topic)
    service.serve(server)
    service.wait()
6) service.serve(server)方法内将刚才创建的RpcService实例启动
def serve(server, workers=none):
    global _launcher
    if _launcher:
        raise runtimeerror(_('serve() can only be called once'))
    _launcher = service.launch(server, workers=workers)
7) 看一下launch方法，因为RpcService没有workers参数，所以走else逻辑，会在当前进程中启动一个新的线程，在线程中启动服务；WsgiService使用的是ProcessLauncher，会单独启动进程
def launch(service, workers=none):
    if workers:
        launcher = processlauncher()
        launcher.launch_service(service, workers=workers)
    else:
        launcher = servicelauncher()
        launcher.launch_service(service)
    return launcher
8) 启动服务的时候，会将self.run_service方法，当做参数传递给add_thread方法
    @staticmethod
    def run_service(service):
        service.start()
        service.wait()
    def launch_service(self, service):
        service.backdoor_port = self.backdoor_port
        self._services.add_thread(self.run_service, service)
9) 在add_thread方法中，会从线程池中spawn一个新的线程出来，此线程就会执行callback方法，也就是run_service函数，启动服务
    def add_thread(self, callback, *args, **kwargs):
        gt = self.pool.spawn(callback, *args, **kwargs)
        th = thread(gt, self)
        self.threads.append(th)
10) 看一下最重要的service.start方法，此方法最重要的是建立了AMQP连接，并创建了三个consumer来接受消息队列的消息，start执行完成之后，当前进程就能够从AMQP 队列中接收消息了
    def start(self):
        verstr = version.version_string_with_package()
        log.audit(_('starting %(topic)s node (version %(version)s)'),
                  {'topic': self.topic, 'version': verstr})
        self.basic_config_check()
        self.manager.init_host()
        self.model_disconnected = false
        ctxt = context.get_admin_context()
        try:
            self.service_ref = self.conductor_api.service_get_by_args(ctxt,
                    self.host, self.binary)
            self.service_id = self.service_ref['id']
        except exception.notfound:
            self.service_ref = self._create_service_ref(ctxt)
        if self.backdoor_port is not none:
            self.manager.backdoor_port = self.backdoor_port
        self.conn = rpc.create_connection(new=true)
        log.debug(_("creating consumer connection for service %s") %
                  self.topic)
        self.manager.pre_start_hook(rpc_connection=self.conn)

```
