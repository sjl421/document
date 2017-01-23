```
rpc_server.py:
[python] 
#!/usr/bin/env python
import pika
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.queue_declare(queue='rpc_queue')
def fib(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fib(n-1) + fib(n-2)
def on_request(ch, method, props, body):
    n = int(body)
    print " [.] fib(%s)"  % (n,)
    response = fib(n)
    ch.basic_publish(exchange='',
                     routing_key=props.reply_to,
                     properties=pika.BasicProperties(correlation_id = \
                                                     props.correlation_id),
                     body=str(response))
    ch.basic_ack(delivery_tag = method.delivery_tag)
channel.basic_qos(prefetch_count=1)
channel.basic_consume(on_request, queue='rpc_queue')
print " [x] Awaiting RPC requests"
channel.start_consuming()

rpc_client.py: 
[python] 
#!/usr/bin/env python
import pika
import uuid
class FibonacciRpcClient(object):
    def __init__(self):
        self.connection = pika.BlockingConnection(pika.ConnectionParameters(
                host='localhost'))
        self.channel = self.connection.channel()
        result = self.channel.queue_declare(exclusive=True)
        self.callback_queue_name = result.method.queue
        self.channel.basic_consume(self.on_response, no_ack=True,
                                   queue=self.callback_queue_name)
    def on_response(self, ch, method, props, body):
        if self.corr_id == props.correlation_id:
            self.response = body
    def call(self, n):
        self.response = None
        self.corr_id = str(uuid.uuid4())
        self.channel.basic_publish(exchange='',
                                   routing_key='rpc_queue',
                                   properties=pika.BasicProperties(
                                         reply_to = self.callback_queue_name,
                                         correlation_id = self.corr_id,
                                         ),
                                   body=str(n))
        while self.response is None:
            self.connection.process_data_events()
        return int(self.response)
fibonacci_rpc = FibonacciRpcClient()
print " [x] Requesting fib(30)"
response = fibonacci_rpc.call(30)
print " [.] Got %r" % (response,)
　　client的basic_publish函数调用的地方增加了reply_to的方法，即发送消息之后，在server处理完成后，需要调用client的一个方法，从而完成RPC的操作。
3.1.5 Nova服务使用rabbitmq介绍
1) 服务创建的exchange和queue
组件
Exchange
Queue
Routing_key
type
nova-api
msgid(每个call都有单独的msgid)
msgid
msgid
direct
Nova-scheduler
nova(conf.control_exchange)
scheduler
scheduler
topic


scheduler.host
注：host为部署服务的host名，下同
scheduler.host
topic

scheduler_fanout
scheduler_fanout_hostid
scheduler_fanout_hostid
fanout

msgid(每个call都有单独的msgid)
msgid
msgid
direct
Nova-compute
nova(conf.control_exchange)
compute
compute
topic


compute.host
compute.host
topic

compute_fanout
compute_fanout_hostid
compute_fanout_hostid
fanout

msgid(每个call都有单独的msgid)
msgid
msgid
direct
注：g版本的direct类型的exchange，可以统一只使用一个公用的queue
a) Api到scheduler
如果部署多scheduler，同api到compute的模式
b) Api到compute
c) Scheduler到compute
　　同api到compute
d) Compute到scheduler
　　同api到scheduler
2) 服务的启动 
　　根据以上分析可知，nova组件服务启动时会创建TopicConsumer，以“nova-compute”服务启动为例，在服务的启动过程中，会调用service::start()方法，在该方法中：
a) conn是什么？
　　conn是nova.openstack.common.amqp.ConnectionContext对象，这个对象是由RPC实现类调用create_connection()方法创建。RPC在openstack中有四种实现：
　　具体使用哪一种根据配置文件确定，默认的配置项是：
rpc_backend=nova.rpc.impl_kombu
     ConnectionContext对象包含两个字段：
* connection_pool：一个Connection对象池（继承自eventlet.pools.Pool），用于生成Connection对象。
* connection：由connection_pool 生成。nova.openstack.common.rpc.impl_komku.Connection对象。该对象在初始化时，会根据配置的参数和策略连接RabbitMQ服务器。
b) rpc_dispatcher是什么？ 
　　RpcDispatcher对象。该对象中有属性callbacks，是一个包含ComputeManager对象的列表。用于接收到消息之后的处理。
c) 三个create_consumer方法干了什么？ 
　　以第一个为例，在该函数中，创建了TopicConsumer对象。
使用消息队列时有如下几个（Consumer类）属性：
* Durable：该属性决定了交换器和队列是否持久化，如持久化，则交换器和队列在RabbitMQ服务重启后仍然继续工作，否则交换器和队列的信息被清空。AMQP协议规定，持久化的队列只能绑定到持久化的交换器。
* Auto_delete：如果设置，则当所有队列结束后，交换器自动删除。默认为False。
* Exclusive：队列是否私有，如果该属性设置，则Auto_delete属性会自动生效。默认为False。
* Auto_ack：收到消息时是否自动发送回执。默认是False，要求消息接收者手动处理回执。
* No_ack：如果设置会提高性能，但会降低可靠性。
* Delivery_mode：消息的传输类型。目前RabbitMQ支持两种类型：
1或者“transient”：消息存储在内存，当服务器宕机或重启时消息丢失
2或者“persistent”：消息会同时在内存和硬盘保存，服务器宕机或重启时消息不丢失
默认为2。
d) consume_in_thread方法 
　　在方法的实现里，又借助了evlentlet库创建超线程。在超线程主函数中调用了TopicConsumer对象的consume()方法（该类没有实现该方法，直接调用父类）。
?
?	对消息的处理包括：从消息中获取接口名称、获取接口参数、调用ComputeManager对象相应方法。
?	至此，“nova-compute”服务启动完成。
3) 消息的发送 
　　以创建虚拟机为例，经过Scheduler模块的过滤后，将创建虚拟机消息发送到对应的compute节点。
     ??
　　?cast_to_compute_host方法的实现：
?
　　　　rpc.cast最终会创建一个TopicPublisher对象，并调用该对象的send方法。
?	由上可知，TopicConsumer对象会向名为“nova”的exchange上， 以 “compute.host”为routing-key发送消息。此时消息会发送到在名为“compute.host”队列上监听的TopicConsumer对象。
3.1.6 Rabbitmq问题定位
1) 问题描述
　　部署场景：控制中心部署rabbitmq-server和openstack服务，计算节点正常部署openstack服务。控制节点和计算节点运行正常，保持计算节点运行正常，重启控制中心单板，待单板复位所有服务正常运行后，无法通过Rabbitmq转发消息创建虚拟机。
2) 问题定位：
a) 如上不重启控制中心节点，重启rabbitmq-server服务，可正常转发消息和创建虚拟机。
b) 断开控制中心和计算中心的网络然后重启rabbitmq-server服务问题重现，无法转发消息。
c) 环境恢复后通过rabbitmqctl list_queues命令查看队列情况，计算节点没有触发重连rabbitmq-server，队列没有生成。导致消息无法转发。
d) 分析openstack rabbitmq封装代码如下：
　　当单板重启时，rabbitmq consumer和server之间的tcp连接依然存在，没有检测到异常，所以没有触发重连。
　　而当Rabbitmq-server服务重启时检测到socket closed的异常所以当rabbitmq-server服务重启后触发重连。
3) 问题解决
解决方案一：打开rabbitmq-server持久化功能，当rabbitmq-server重启后队列持久化转发消息
解决方案二: 需要rabbit的keepalive的heartbeat检测，检测异常然后重连。
最终解决方案：考虑到后续可靠性因素选用方案一。
3.2 WSGI标准
3.2.1 简介
　　本文档描述一份在web服务器与web应用/web框架之间的标准接口，此接口的目的是使得web应用在不同web服务器之间具有可移植性。
3.2.2 基本原理与目标
　　python目前拥有大量的web框架，比如 Zope, Quixote, Webware, SkunkWeb, PSO, 和Twisted Web。大量的选择使得新手无所适从，因为总得来说，框架的选择都会限制web服务器的选择。
　　对比之下，虽然java也拥有许多web框架，但是java的" servlet" API使得使用任何框架编写出来的应用程序可以在任何支持" servlet" API的web服务器上运行。服务器中这种针对python的API（不管服务器是用python写的，还是内嵌python，还是通过一种协议来启动python）的使用和普及，将分离人们对web框架和对web服务器的选择，用户可以自由选择适合他们的组合，而web服务器和web框架的开发者也能够把精力集中到各自的领域。
　　因此，这份PEP建议在web服务器和web应用/web框架之间建立一种简单的通用的接口规范，Python Web Server Gateway Interface (WSGI).
　　但是光有这么一份规范对于改变web服务器和web应用/框架的现状是不够的，只有web服务器和web框架的作者们实现WSGI，他才能起应有的效果。
　　然而，既然还没有任何框架或服务器实现了WSGI，对实现WSGI也没有什么直接的奖励，那么WSGI必须容易实现，这样才能降低作者的初始投资。
　　服务器和框架两边接口的实现的简单性，对于WSGI的作用来说，绝对是非常重要的。所以这一点是任何设计决策的首要依据。
　　对于框架作者来说，实现的简单和使用的方便是不一样的。WSGI为框架作者展示一套绝对没有"frills"的接口，因为象response对象和对cookie的处理这些问题和框架现有的对这些问题的处理是矛盾的。再次重申一遍，WSGI的目的是使得web框架和web服务器之间轻松互连，而不是创建一套新的web框架。
　　同时也要注意到，这个目标使得WSGI不能依赖任何在当前已部署版本的python没有提供的任何功能，因此，也不会依赖于任何新的标准模块，并且 WSGI并不需要2.2.2以上版本的python(当然，在以后的python标准库中内建支持这份接口的web服务器也是个不错的主意)
　　不光要让现有的或将要出现的框架和服务器容易实现，也应该容易创建请求预处理器、响应处理程序和其他基于WSGI的中间件组件，对于服务器来说他们是应用程序，而对于他们包含的应用程序来说他们是服务器。
　　如果中间件既简单又健壮，而且WSGI广泛得实现在服务器和框架中，那么就有可能出现全新的python web框架：整个框架都是由几个WSGI中间件组件组成。甚至现有框架的作者都会选择重构将以实现的服务以这种方式提供，变得更象一些和WSGI配合使用的库而不是一个独立的框架。这样web应用开发这就可以根据特定功能选择最适合的组件，而不是所有功能都由同一个框架提供。
　　当然，这一天无疑还要等很久，在这之间，一个合适的短期目标就是让任何框架在任何服务器上运行起来。
　　最后，需要指出的是当前版本的WSGI并没有规定一个应用具体以何种方式部署在web服务器或gateway上。目前，这个需要由服务器或 gateway的具体实现来定义。如果足够多实现了WSGI的服务器或gateway通过领域实践产生了这个需求，也许可以产生另一份PEP来描述 WSGI服务器和应用框架的部署标准。
3.2.3 概述
　　WSGI接口有两种形式：一个是针对服务器或gateway的，另一个针对应用程序或框架。
　　服务器接口请求一个由应用接口提供的可调用的对象，至于该对象是如何被请求的取决与服务器或gateway。我们假定一些服务器或gateway会需要应用程序的部署人员编写一个简短的脚本来启动一个服务器或 gateway的实例，并把应用程序对象提供得服务器，而其他的服务器或gateway需要配置文件或其他机制来指定从哪里导入或者获得应用程序对象。
　　除了纯粹的服务器/gateway和应用程序/框架，还可以创建实现了这份规格说明书的中间件组件，对于包含他们的服务器他们是应用程序，而对于他们包含的应用程序来说他们是服务器，他们可以用来提供可扩展的API，内容转换，导航和其他有用的功能。
　　在整个规格说明书中，我们使用短语"一个可调用者"意思是"一个函数，方法，类，或者拥有__call__ 方法的一个对象实例",这取决与服务器，gateway，应用程序根据需要而选择的合适实现方式。相反服务器，gateway和请求一个可调用者的应用程序不可以依赖具体的实现方式，not introspected upon.

```
