```
OpenStack 

献给那些有云计算背景知识，准备投身OpenStack学习和研究的开发者们 

开源社区 
.开源社区不仅仅是一种生产模式，同时也是一种基于项目活动之上
的交流模式。社区不会强制成员该怎么做，它只会鼓励成员该怎么做。 
.本质：一群技术人员 
–开源精神：开放、互助、参与、分享 
–对项目有兴趣：乐于参与项目的运作、开发、测试、维护等 
–主要来源：与项目利益相关的企业/组织、个人开发者、科研机构 

.开源项目核心成员的主要特征 
–开发能力强，经验丰富 
.对项目所在领域的产品或者类似项目的理解和参与经验，对项目所在领域核心技术的掌握 
.对项目的设计思想、架构演进、关键特性实现等方面的理解 
.较高的代码质量 

–长期跟踪项目，并作出个人贡献 
.参与设计，实现feature，修正bug，review代码等等 

–项目的核心负责人 
.具备项目经理和产品经理的双重技能 
.从项目创始初期即作为核心贡献者参与项目 

背景知识和必备技能 
.ReST 
.虚拟化 (libvirt, kvm, openvswitch, lvm, ceph...) 
.数据库 (Mysql, PostgreSQL) 
.消息队列服务 (RabbitMQ, ZeroMQ, Qpid) 
.技多不压身... 

1 背景知识 
2 必备技能 
. 英文 
. Python 
. Google 

参考和求助 
.上策 
–http://ask.openstack.org/ 
–OpenStack General mailing list (openstack@lists.openstack.org) 
–OpenStack Development mailing list (openstack-dev@lists.openstack.org) 
–IRC (https://wiki.openstack.org/wiki/IRC) 

.中策 
–找同事咨询 
–在QQ群、微信群、博客或微博公开求助 
.清晰描述问题出现的版本、相关配置、日志、初步的排错过程等 

.下策 
–自己憋着 

.上策 
–OpenStac官方文档, OpenStack Wiki, Google doc, README 

.中策 
–国内外大牛的技术博客 

.下策 
A: 你那儿有没有OpenStack的资料，给我发一下，我学习学习？ 
我：... 

参考 – 权威、不过时 

求助 – 要想得到一个好答案，先从一个好问题开始 √ 

Step1 架构 

Step2 实际部署 
.操作系统 
–Ubuntu, Red Hat Enterprise Linux, SUSE... 

.手动安装 
–http://docs.openstack.org/icehouse/install-guide/install/apt/content/ 
–交换机配置 

.自动安装 
–DevStack (http://devstack.org/) 
–Fuel from Mirantis (https://wiki.openstack.org/wiki/Fuel) 
–Compass from Huawei (https://wiki.openstack.org/wiki/Compass) 
–离线 all-in-one ISO from Huawei 
(http://lingxiankong.github.io/blog/2014/04/29/openstack-icehouse-allinone) 
–... 

Step3 使用OpenStack 
.Horizon 

Step3 使用OpenStack 
.cURL 

root@openstack:~# $ curl -i 'http://127.0.0.1:5000/v2.0/tokens' -X POST 
-H "Content-Type: application/json" -H "Accept: application/json" -d 
'{"auth": {"tenantName": "admin", "passwordCredentials": {"username": 
"admin", "password": "devstack"}}}' 
. Postman 

Step3 使用OpenStack 
.OpenStack command-line clients 
–http://docs.openstack.org/cli-reference/content/ 

.OpenStack Python SDK (http://developer.openstack.org/) 

    from os import environ as env 
    import novaclient.v1_1.client as nvclient 
    
    nova = nvclient.Client(auth_url=env['OS_AUTH_URL'], 
    
     username=env['OS_USERNAME'], 
    
     api_key=env['OS_PASSWORD'], 
    
     project_id=env['OS_TENANT_NAME'], 
    
     region_name=env['OS_REGION_NAME']) 
    
    print(nova_client.servers.list()) 

Step4 Under the hood 
OpenStack 

Step5 Contribution 
.文档的bug修复 
.带有low-hanging-fruit标签的bug 
.参与代码review 
.Tempest门槛用例，大牛们都很忙 
.bug提交和修复 
.blueprint的提交和实现 
.为社区撰写文档 

Step5 Contribution 
    Corporate Contributor License Agreement 
    Create launchpad account 
    Join OpenStack Foundation 
    Sign the CLA 
    Setup&Config Git 
    Upload SSH 
    Find a Bug 
    Fix & Commit & Review & Merge 
    Congratuations 

Step5 Contribution 
https://launchpad.net/+login, 同时可以登录Gerrit，Jenkins 
注意：邮件地址很重要，后面还会用到 Corporate Contributor License Agreement 
Create launchpad account 
Join OpenStack Foundation 
```
