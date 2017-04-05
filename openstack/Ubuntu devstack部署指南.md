## Ubuntu devstack部署指南
### 1.配置apt-get更新源
    vi /etc/apt/sources.list
    deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
    
### 2.clone devstack源代码
    git clone http://git.trystack.cn/openstack-dev/devstack -b stable/ocata .
    
### 3.创建stack用户
    cd devstack
    ./tools/create-stack-user.sh
    
### 4.配置pip镜像使用国内
    vi ~/.pip/pip.conf
    [global]
    index-url = https://pypi.douban.com/simple
    download_cache = ~/.cache/pip
    [install]
    use-mirrors = true
    mirrors = http://pypi.douban.com/
    
> stack和root用户都要配置

### 5.配置git镜像使用国内
    cd devstack
    vi local.conf
    HOST_IP=a.b.c.d  --->本地IP地址
    # use TryStack git mirror
    GIT_BASE=http://git.trystack.cn
    NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
    SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
    
### 6.执行安装脚本
    cd devstack
    ./stack.sh
