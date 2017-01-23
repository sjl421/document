```
     Volume Workers用来管理基于LVM（Logical Volume Manager）的实例卷。Volume Workers有卷的相关功能，例如新建卷、删除卷、为实例附加卷，为实例分离卷。卷为实例提供一个持久化存储，因为根分区是非持久化的，当实例终止时对它所作的任何改变都会丢失。当一个卷从实例分离或者实例终止（这个卷附加在该终止的实例上）时，这个卷保留着存储在其上的数据。当把这个卷重附加载相同实例或者附加到不同实例上时，这些数据依旧能被访问。一个实例的重要数据几乎总是要写在卷上，这样可以确保能在以后访问。这个对存储的典型应用需要数据库等服务的支持。
2.2.6 Scheduler (nova-scheduler)
     调度器作为一个称为nova-schedule守护进程运行，通过恰当的调度算法从可用资源池获得一个计算服务。Scheduler会根据诸如负载、内存、可用域的物理距离、CPU构架等作出调度决定。nova scheduler实现了一个可插入式的结构。
     Scheduler做的工作就是在创建实例(instance)时，为实例找到合适的主机(host)，这个过程分为两步：首先是过滤(filter)， 从所有的主机中找到符合实例运行条件的主机，然后从过滤出来的主机中，找到最合适的一个主机。
2.3 Nova部署图
2.4 Nova对外提供功能以及周边依赖
2.5 Nova逻辑视图
2.6 Nova-api启动流程图
2.7 Nova-api处理请求流程


3 基础知识篇
3.1 RabbitMQ
3.1.1 F版本中rabbitmq的应用
　　以nova服务为例，经典的部署方式中（一个controller节点，多个compute节点），RabbitMQ所处的位置，由此可见，rabbitmq承载着服务内部各子服务间的消息通讯：
3.1.2 G版本中rabbitmq的应用
　　在Grizzly版的Nova中，出于安全及维护的考虑，取消了nova-compute的直接数据库访问，取而代之的是在controller端新增了nova-conductor服务，compute端的数据库访问转变位rpc消息通知到conductor服务，由conductor服务统一进行数据处理。
这也就意味着Controller节点将比以前运行更多的任务，负载变重，因此有必要对负载做监控，必要时需要扩展contorller服务。Rabbitmq将会承载更多的消息通讯（原db访问也转换为消息通讯）;?
　　当在多个节点运行nova-api时，就需要在前端做负载均衡；多个节点运行nova-scheduler或nova-conductor时，负载均衡的任务就由消息队列服务器完成；
　　在大规模部署的情况下，势必会对单节点的RabbitMQ server造成较大的负载，一旦发生单节点故障，整个openstack服务都会瘫痪。所以，部署时可以考虑使用RabbitMQ的HA等高级部署特性，具体参见RabbitMQ相关文档，在此不再赘述。
3.1.3 rabbitmq基本介绍
1) 基本概念
　RabbitMQ的结构图如下：
　　几个概念说明：
Broker：简单来说就是消息队列服务器实体。
Exchange：消息交换机，它指定消息按什么规则，路由到哪个队列。
Queue：消息队列载体，每个消息都会被投入到一个或多个队列。
Binding：绑定，它的作用就是把exchange和queue按照路由规则绑定起来。
Routing Key：路由关键字，exchange根据这个关键字进行消息投递。
vhost：虚拟主机，一个broker里可以开设多个vhost，用作不同用户的权限分离。
producer：消息生产者，就是投递消息的程序。
consumer：消息消费者，就是接受消息的程序。
channel：消息通道，在客户端的每个连接里，可建立多个channel，每个channel代表一个会话任务。
　　消息队列的使用过程大概如下：
a) 客户端连接到消息队列服务器，打开一个channel。
b) 客户端声明一个exchange，并设置相关属性。
c) 客户端声明一个queue，并设置相关属性。
d) 客户端使用routing key，在exchange和queue之间建立好绑定关系。
e) 客户端投递消息到exchange。
　exchange接收到消息后，就根据消息的key和已经设置的binding，进行消息路由，将消息投递到一个或多个队列里。
2) Exchange类型
a) Topic和Direct
? Cast（异步操作）
同步操作，无响应；
　　对key进行模式匹配后进行投递，符号”#”匹配一个或多个词，符号”*”匹配正好一个词。例如”abc.#”匹配”abc.def.ghi”，”abc.*”只匹配”abc.def”；
? Call（同步操作）
异步操作，需响应；
　　对key进行模式匹配后进行投递，符号”#”匹配一个或多个词，符号”*”匹配正好一个词。例如”abc.#”匹配”abc.def.ghi”，”abc.*”只匹配”abc.def”；
消息发布者，在进行rpc.call调用时，会创建direct consumer用于接收响应，创建一个direct类型的exchange（名字为发送消息的msgid），创建一个绑定key为msgid的队列；
消息接收者，处理完消息时，按指定的exchange和key（msgid）返回响应消息；
b) Fanout
一般用于cast的同步操作；
不需要key，采取广播模式，一个消息进来时，投递到与该交换机绑定的所有队列。
3) 可靠性因素
a) Mirror功能
　　提供队列mirror功能，通过这一功能可以提高rabbitMQ的可靠性；当某个rabbitmq故障时，只要其他节点里存在该故障节点的队列镜像，该队列就能正常工作不会丢失数据。
但使用该功能有一定的副作用，它通过冗余数据保障可靠性的方式会降低系统的性能，因为往一个队列发送数据也就会往这个队列的所有副本中发数据，必然会导致大量rabbitmq节点间的消息交互，降低吞吐率，镜像越多性能下降越厉害。
　　网上有人测试过，一个队列只有一个镜像副本的部署的性能，吞吐率会降低到原来的1/4。
b) 持久化机制
　　RabbitMQ支持消息的持久化，也就是数据写在磁盘上，为了数据安全考虑，我想大多数用户都会选择持久化。消息队列持久化包括3个部分：
（1）exchange持久化，在声明时指定durable => 1
（2）queue持久化，在声明时指定durable => 1
（3）消息持久化，在投递时指定delivery_mode => 2（1是非持久化）
　　如果exchange和queue都是持久化的，那么它们之间的binding也是持久化的。如果exchange和queue两者之间有一个持久化，一个非持久化，就不允许建立绑定。
c) Confirm机制
　　Confirm的作用在于当消息真正持久化到磁盘时，给生产者发送ack确认，若生产者在收到ack确认响应后才丢弃消息，就可以保证消息一定不丢失。但confirm机制一样会带来性能影响，从网上别人的测试数据看，有25%作用的吞吐量下降。如果没有这么高的可靠性要求，可以使用heartbeat检测机制；
d) Heartbeat检测
　与rabbitmq服务器间的连接可以由heartbeat心跳检测，在服务器down掉时，生产者可以及时发现并做相应的处理，减少可能丢失消息的风险。
4) 性能因素
a) 启用发送缓冲区
　　设置发送缓冲区，减少阻塞，网上测试数据，吞吐量有5%作用的提升；
b) 不启用可靠机制
　　可靠性与性能是互相冲突的两个指标，如果不启用mirror,confirm,持久化功能，性能会有相应的提升（见可靠性部分描述）
c) 并发处理
　　调整queue的数量，提供queue的并发处理能力。或集群部署rabbitmq server。
3.1.4 官方文档上的那由浅及深的六个例子
1) Hello World
　　最简单的情况，发一个消息，接收，打印出来这个消息（使用默认的exChange）。
send.py：
[python] 
#!/usr/bin/env python
import pika
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.queue_declare(queue='hello')
channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!')
print " [x] Sent 'Hello World!'"
connection.close()
recv.py：
[python
#!/usr/bin/env python
import pika
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.queue_declare(queue='hello')
print ' [*] Waiting for messages. To exit press CTRL+C'
def callback(ch, method, properties, body):
    print " [x] Received %r" % (body,)
channel.basic_consume(callback,
                      queue='hello',
                      no_ack=True)
channel.start_consuming()
2) Work Queues 
　　这个例子跟第一个例子基本上一样，只是启动了多个consumer，并且模拟真实情况，即发送的消息使得consumer在短时间内不能完成工作。该测试需要起2个Consumer，1个productor。在这种情况下，多个consumer是间隔地接收到消息。这个用例为了保证消息尽量不丢失，增加了保护机制（发送端增加了将delivery_mode设置为2表示持久化消息，接收端增加了act为true表示需要回应接收到消息）。
new_task.py
[python] 
#!/usr/bin/env python
import pika
import sys
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
#durable为true表示队列或exchange会在rabbitMq重启时重新建立
channel.queue_declare(queue='task_queue', durable=True)
message = ' '.join(sys.argv[1:]) or "Hello World!"
channel.basic_publish(exchange='',
                      routing_key='task_queue',
                      body=message,
                      properties=pika.BasicProperties(
                         delivery_mode = 2, #表示消息是持久化的
                      ))
print " [x] Sent %r" % (message,)
connection.close()
new_work.py: 
[python]
#!/usr/bin/env python
import pika
import time
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
#durable为true表示队列或exchange会在rabbitMq重启时重新建立
channel.queue_declare(queue='task_queue', durable=True)
print ' [*] Waiting for messages. To exit press CTRL+C'
def callback(ch, method, properties, body):
    print " [x] Received %r" % (body,)
    time.sleep( body.count('.') )
    print " [x] Done"
    ch.basic_ack(delivery_tag = method.delivery_tag)
#客户端在处理一个消息时，不会再去获取新消息，避免客户端CPU占用率太高
channel.basic_qos(prefetch_count=1)
channel.basic_consume(callback, queue='task_queue')
channel.start_consuming()
　　此处增加可靠性后，消息会一直缓存在系统中。通过rabbitmqctl命令，可以查看系统中有哪些消息是缓存着的。
rabbitmqctl list_queues name messages_ready messages_unacknowledged
3)  Pulish/Subscribe的例子

```
