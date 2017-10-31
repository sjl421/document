## AWS Overview
| Service | Function |
| ------- | -------- |
| ECS | 提供elastic计算资源，分为两种：1.一般的操作系统；2.提供容器的功能 |
| ELB | 提供负载均衡的功能，国内版的AWS ELB有2中类型（Network，Classic），国际版的AWS ELB有3种类型（Application，Network，Classic）|
| S3 | 提供对象存储服务 |
| ECS | 提供容器管理的功能，类似kubernetes，docker swarm的集群管理工具 |
| Api Gateway | 提供restful api的功能，需要定义api的get/post/delete方法，后端可以基于http于elb，ec2集成，也可以与aws的其他服务集成|
| Lambda | 基于事件的函数处理，支持java，php，ruby，node.js等大多数传统语言，用户无需关注函数的运行环境 |
| RDS | 提供关系型数据库服务 |
| VPC | 在云端隔离私有网络的功能 |
| IAM | 账户权限控制的功能，包括user，role，policy等 |
| ElasticCache | 提供缓存的功能，其中包括redis，memcache等 |
| CloudWatch | 资源监控和报警的功能 |
| SQS | 消息队列的功能 |
| SNS | 通知的功能 |
