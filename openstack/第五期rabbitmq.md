# RabbitMQ #
## RabbitMQ作用 ##
RabbitMQ负责消息总线，同一个Service之间的组件相互通信是通过RabbitMQ完成的，不同Service的通信是通过HTTP完成的。
## RabbitMQ持久化 ##
1. exchange,queue,message没有做持久化处理
2. ack有持久化处理

## call与cast的区别 ##
1. call是有返回的，生产消息的时候同时把返回的消息通道建立起来，message id是唯一的，回传的时候message id不变
2. cast是没有返回的，一次message传递
