# Glance #
glance提供镜像服务。根据不同的driver提供不同的存储后端，可以有多个location（URL）。创建image的流程：image-factory --(new image)--> image --(add to)--> image-repo
glance是可以缓存的，缓存在安装glance service节点的本地，支持sqlite driver和xatrr driver。

数据盘和系统盘创建2个镜像。
glance不感知镜像文件格式，以前是什么格式，就存储什么格式。

# Swift #
对象存储服务，非结构化存储，分布式，存储的不是文件是对象。
一致性哈希
完全对称，面向资源分布式
