# Kubernetes (K8S)中的主要概念 #
* Container：容器，目前主流是Docker，未来K8S也将全面支持RKT（CoreOS）
* Pod：一组紧耦合的容器，共享IP，存储等，是K8S中部署的最小单元
* Service：一组提供相同服务的Pod共同连接的一个逻辑层，服务的使用者直接访问Service，而不是具体的Pod
* Controller：以“观察-对比-行动”保证目标对象符合用户的期望。例如Replication Controller，保证群组中Pod数目稳定
* Label&Selector：K8S中的一切对象都可以标记Label，通过Selector可以灵活的对API对象进行组合

# 资源管理 #
## 资源管理从2个角度看： ##
* 从应用的角度，为每个Pod寻找合适的部署节点，保证用户体验

    - 调度器（Scheduler）
    - 资源QoS（Resource Quality of Service）
    - 自动弹性（横向/纵向）（Auto-Scaling，Vertical/Horizontal）

* 从集群的角度，提高资源利用率，控制租户的资源配额

    - 资源超售（Oversubscription）
    - 多租户资源配额管理（LimitRange and Quota）
    - 资源再平衡（Rescheduling）
    - 实时监控

# 我们需要什么样的调度器 #
* 把Pod放到合适的节点上，但什么才是“合适”的？

    - Pod基本的资源需求
    - Pod的约束条件：多维度的亲和与反亲和（Affinity & Anti-Affinity）
    - 集群整体的资源利用率，资源平衡

* 业务上的需求

    - 调度的效率，调度的决策要快
    - 能够为不同类型的应用（Pod）设置不同的调度规则

* 调度器的架构优化

    - 降低api-server的处理压力：调度器与api-server解耦，作为独立的进程异步运行
    - 插件式的调度器设计，方便用户添加自定义的调度规则

# 节点选择的工程 #
为待部署的Pod选择节点包括过滤和打分两个步骤：
* 过滤：

    - 用一系列过滤函数（predicate），把不满足Pod基本部署条件的节点筛选出去
    - 资源剩余，部署约束（Label检查，服务分散等）

* 打分：

    - 用一系列优先级函数（prioritizer），为满足条件的节点打分，选择分数最高的
    - 资源剩余，资源平衡，Label检查，服务分散等
