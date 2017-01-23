```
　　前两个例子中exchange都是默认的（basic_publish的exchange的参数为空），下面的用例增加了对exchange的设置。
emit_log.py:
[python] 
#!/usr/bin/env python
import pika
import sys
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='logs',
                         type='fanout')
message = ' '.join(sys.argv[1:]) or "info: Hello World!"
channel.basic_publish(exchange='logs',
                      routing_key='',
                      body=message)
print " [x] Sent %r" % (message,)
connection.close()
receive_logs.py: 
[python] 
#!/usr/bin/env python
import pika
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='logs',
                         type='fanout')
#创建一个匿名队列，名字保存在result.method.queue中
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue
#将队列和exchange绑定
channel.queue_bind(exchange='logs',
                   queue=queue_name)
print ' [*] Waiting for logs. To exit press CTRL+C'
def callback(ch, method, properties, body):
    print " [x] %r" % (body,)
channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)
channel.start_consuming()
　　通过rabbitmqctl命令，可以查看RabbitMQ中exchange和queue绑定情况
rabbitmqctl list_bindings
4)  Routing的例子： 
　　一个queue是可以和同一个exchange多次绑定的，每次绑定要用不同的routing_key。发送消息的时候可以指定 routing_key，接收消息方可以指定条件决定要接收哪些 routing_key的消息。
emit_log_direct.py:
[python] 
#!/usr/bin/env python
import pika
import sys
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='direct_logs',
                         type='direct')
severity = sys.argv[1] if len(sys.argv) > 1 else 'info'
message = ' '.join(sys.argv[2:]) or 'Hello World!'
channel.basic_publish(exchange='direct_logs',
                      routing_key=severity,
                      body=message)
print " [x] Sent %r:%r" % (severity, message)
connection.close()
receive_logs_direct.py: 
[python] 
#!/usr/bin/env python
import pika
import sys
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='direct_logs',
                         type='direct')
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue
severities = sys.argv[1:]
if not severities:
    print >> sys.stderr, "Usage: %s [info] [warning] [error]" % \
                         (sys.argv[0],)
    sys.exit(1)
for severity in severities:
    channel.queue_bind(exchange='direct_logs',
                       queue=queue_name,
                       routing_key=severity)
print ' [*] Waiting for logs. To exit press CTRL+C'
def callback(ch, method, properties, body):
    print " [x] %r:%r" % (method.routing_key, body,)
channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)
channel.start_consuming()
5)  Topic exchange的例子 
　　这里的routing_key可以使用一种类似正则表达式的形式，但是特殊字符只能是“*”和“#”（“*”代表一个单词，“#”代表0个或是多个单词）。这样发送过来的消息如果符合某个queue的routing_key定义的规则，那么就会转发给这个queue。如下图示例：
　　下面的例子是根据命令行传入的参数，来决定接收端接收哪些消息。
emit_log_topic.py:
[python] 
#!/usr/bin/env python
import pika
import sys
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='topic_logs',
                         type='topic')
routing_key = sys.argv[1] if len(sys.argv) > 1 else 'anonymous.info'
message = ' '.join(sys.argv[2:]) or 'Hello World!'
channel.basic_publish(exchange='topic_logs',
                      routing_key=routing_key,
                      body=message)
print " [x] Sent %r:%r" % (routing_key, message)
connection.close()
receive_logs_topic.py: 
[python] 
#!/usr/bin/env python
import pika
import sys
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='topic_logs',
                         type='topic')
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue
binding_keys = sys.argv[1:]
if not binding_keys:
    print >> sys.stderr, "Usage: %s [binding_key]..." % (sys.argv[0],)
    sys.exit(1)
for binding_key in binding_keys:
    channel.queue_bind(exchange='topic_logs',
                       queue=queue_name,
                       routing_key=binding_key)
print ' [*] Waiting for logs. To exit press CTRL+C'
def callback(ch, method, properties, body):
    print " [x] %r:%r" % (method.routing_key, body,)
channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)
channel.start_consuming()
发送时需要指定消息的routing_key，如果为空则为“anonymous.info”。例如：
    python emit_log_topic.py my.test
接收时指定具体的routing_key接收消息，例如：
    python receive_logs_topic.py my.test
如果想接收全部的消息：
    python receive_logs_topic.py "#"
如果想接收以"kern"开头，且后续伴有一个单词的消息:
    python receive_logs_topic.py "kern.*"
如果想接收以"critical"结尾，且前面有任意一个单词的消息:
    python receive_logs_topic.py "*.critical"
或者想接收上述两种组合的消息
    python receive_logs_topic.py "kern.*" "*.critical"
6) PRC(Remote Procedure Call，远程过程调用) 
　　目前对这个的理解就是发送一个消息，然后还要得到一个结果，即消息要走一个来回。如下图所示：
　　下面的例子假设Server提供一个计算fib数列的服务，Client通过RPC调用该服务。

```
