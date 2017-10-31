## 使用SDK创建aws ecs cluster
### 一.创建一个空的cluster
### 二.启动container ec2
#### ec2有2中AMI镜像
- 一种是普通的AMI镜像，镜像包括一般的操作系统和一些常用的命令
- 另一种AMI是容器镜像，镜像内部预安装了docker容器和容器的agent

#### 1.容器AMI有如下：
| Region | AMI ID |
| ------ | ------ |
|us-east-2| ami-34032e51
|us-east-1 |ami-ec33cc96
|us-west-2 |ami-29f80351
|us-west-1 |ami-d5d0e0b5
|eu-west-2 |ami-eb62708f
|eu-west-1 |ami-13f7226a
|eu-central-1| ami-40d5672f
|ap-northeast-1| ami-21815747
|ap-southeast-2| ami-4f08e82d
|ap-southeast-1 |ami-99f588fa
|ca-central-1 |ami-9b54edff

#### 2.设置IAM role
- ecsInstanceRole
- If you do not launch your container instance with the proper IAM permissions, your
Amazon ECS agent cannot connect to your cluster.（如果不设置role的话，ecs的agent将不能够连接到cluster）

#### 3.在启动ecs container（ec2）的时候注入cluster的名字，ecs container的默认名字是default

#### 4.ecs container注入cluster的方法
- 将下面的内容或者文件注入到ecs container中

```
#!/bin/bash
echo ECS_CLUSTER=your_cluster_name >> /etc/ecs/ecs.config
```

#### 5.启动ecs container注入以上文件内容后，就不需要register container instance，ecs container启动后会自动注册到指定的cluster中“your_cluster_name”
