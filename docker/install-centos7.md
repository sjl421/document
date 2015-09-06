# centos7安装docker #
## 一，准备 ##
1. centos7 x86-64
2. 查看版本：  
    >`uname -r`  
    >`3.10.0-229.11.1.el7.x86_64`  

## 二，安装docker ##
1. 更新系统：  
    `yum update -y`
2. 添加docker版本仓库:        
    ```cat >/etc/yum.repos.d/docker.repo <<-EOF  
        [dockerrepo]  
        name=Docker Repository  
        baseurl=https://yum.dockerproject.org/repo/main/centos/7  
        enabled=1  
        gpgcheck=1  
        gpgkey=https://yum.dockerproject.org/gpg  
        EOF```
3. 安装docker：  
    `sudo yum install docker-engine`  
4. 启动Docker daemon：  
    `sudo service docker start`  
5. 验证docker安装是否成功  
    `sudo docker run hello-world`  
6. 创建docker组  
    `sudo usermod -aG docker your_username`  
7. 设置docker开机自启动  
    `sudo chkconfig docker on`
    
## 三，卸载docker ##
1. 列出安装的docker  
    `yum list installed | grep docker`  
2. 删除安装包  
    `sudo yum -y remove docker-engine.x86_64`  
3. 删除数据文件  
    `rm -rf /var/lib/docker`