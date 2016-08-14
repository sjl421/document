# 基础 - 容器 #
* 容器：独立运行一个或一组进程的运行态环境

    - 进程：环境和资源隔离的核心对象

* 操作

    - 运行：docker run -d -args image:tag $command
    - 访问：docker exec -ti $container $command
    - 启停：docker start/stop/rm $container_id

* 通信

    - eth0(native) ---> eth0(container)

# 基础 - 镜像 #
* 镜像：提供进程可执行的环境操作类集合

    - docker commit $container_id repository:tag
    - docker build -t repository:tag . (.表示dockerfile所在目录)

# 基础 - 仓库 #
* docker仓库

    - docker push / pull repository:tag

# 基础 - 网络 #
    docker run -net=$arg repository:tag $command
    
# Demo #
* 启动容器 -> 配置容器参数 -> 查询容器信息 -> 控制容器生命周期

    - 容器参数：文件挂载/端口映射/资源控制

* pull镜像 -> 制作dockerfile -> 制作新镜像 -> 上传到docker仓库
* 开发环境一致性
* 资源隔离模拟测试
