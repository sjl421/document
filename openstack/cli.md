## 安装
    yum install -y python-openstackclient

## 配置OpenStack RC文件
    export OS_USERNAME=username
    export OS_PASSWORD=password
    export OS_TENANT_NAME=projectName
    export OS_AUTH_URL=https://identityHost:portNumber/v2.0
    
## 测试
    1.openstack server list --insecure
    +--------------------------------------+------------------+--------+----------------------------------+------------+
    | ID                                   | Name             | Status | Networks                         | Image Name |
    +--------------------------------------+------------------+--------+----------------------------------+------------+
    | 8b6fa705-ab14-4981-b718-b1e0b9d0bba4 | win7_vm_test_010 | ACTIVE | net1=192.168.1.35                |            |
    | c2685372-7328-4ac9-83cd-0df898c2a441 | win7_vm_test_009 | ACTIVE | net1=192.168.1.34                |            |
    | 7a09c4e4-77ca-488e-a32e-b72ec2536514 | win7_vm_test_008 | ACTIVE | net1=192.168.1.33                |            |
    | 0afa530b-0117-4e2f-a005-f9f8b4f9e690 | win7_vm_test_007 | ACTIVE | net1=192.168.1.32                |            |
    | 2fb4d6a2-b9ae-47e0-8136-aa165a0b8394 | win7_vm_test_006 | ACTIVE | net1=192.168.1.31                |            |
    | 4d327b70-e692-4b3d-92c0-483e8f980fdc | win7_vm_test_005 | ACTIVE | net1=192.168.1.30                |            |
    | 147acb07-7d8b-4a5d-871f-f5c859039149 | win7_vm_test_004 | ACTIVE | net1=192.168.1.29                |            |
    | 5dc0c9d4-064c-4b08-97a2-9b25b68c149e | win7_vm_test_003 | ACTIVE | net1=192.168.1.28                |            |
    | fed7b9bd-17f5-4d12-8abd-edb94589de90 | win7_vm_test_002 | ACTIVE | net1=192.168.1.27                |            |
    | 314fc3db-f661-451c-a22f-940e7d9a792a | win7_vm_test_001 | ACTIVE | net1=192.168.1.26, 10.109.157.20 |            |
    +--------------------------------------+------------------+--------+----------------------------------+------------+
    
    2.openstack router list --insecure
    +--------------------------------------+-----------------------------------------+--------+-------+-------------+-------+----------------------------------+
    | ID                                   | Name                                    | Status | State | Distributed | HA    | Project                          |
    +--------------------------------------+-----------------------------------------+--------+-------+-------------+-------+----------------------------------+
    | 7ebe1e9a-fc19-4e4e-89af-7066d78c7586 | vRouter1                                | ACTIVE | UP    | False       | False | a68c8af954f04d00a2a949b1ec404217 |
    | 8f83b70a-6897-41c7-bb5c-af1f3c3d3e53 | DN-pek_cn_test2                         | ACTIVE | UP    | False       | False | 288e083b209748f9930cdd2bb01ea896 |
    | 904fce01-a85b-4d89-97f1-aeae460e9c02 | vRouter2                                | ACTIVE | UP    | False       | False | a68c8af954f04d00a2a949b1ec404217 |
    | ba00962c-f592-49b6-bb40-13502df34332 | Router_9a59a8342aeb4962be561eade61b4fd5 | ACTIVE | UP    | False       | False | 9a59a8342aeb4962be561eade61b4fd5 |
    | ee4c266e-2667-4004-89e3-51a60ee647db | DN-pekitlab_test1                       | ACTIVE | UP    | False       | False | 288e083b209748f9930cdd2bb01ea896 |
    | fb2fc8f2-ed1a-4a82-bc3c-1602998aedd0 | Router_fbca84ba4b3a447595204b644c047e3e | ACTIVE | UP    | False       | False | fbca84ba4b3a447595204b644c047e3e |
    +--------------------------------------+-----------------------------------------+--------+-------+-------------+-------+----------------------------------+
    
    3.openstack network list --insecure
    +--------------------------------------+-------------------------+--------------------------------------+
    | ID                                   | Name                    | Subnets                              |
    +--------------------------------------+-------------------------+--------------------------------------+
    | 5492a832-fc8d-4ae4-bf78-62303eb57df0 | net1                    | a7ebbd3c-d672-43cb-a41a-1b10581658b2 |
    | 6b27629e-d884-4344-81d6-0e59bf8625f5 | labcloud_03_network     |                                      |
    | 8b7ad34a-d76b-4364-9416-2e4cfaac1b18 | pek_test_env_03_network |                                      |
    | a336c342-2ab5-423d-acfb-3aba4f0c8e3a | internal_base           | c7d6107f-1222-45f1-83b6-c2b0c5decdc8 |
    | b3a323fe-a4cf-4b2f-be93-262704e0a2f9 | VPC001_NET1             | 4837275f-61ba-4b85-a104-5a2856178fa5 |
    | bce0d411-3593-459c-bb19-ba35b234e54c | VPC002_NET1             | b2a05637-0477-4009-8199-17086b99c385 |
    | d91eb1eb-8f2b-41ef-b1b1-8d10e974a793 | GREEN_NAT               | 2936918d-e3f1-4caa-a413-fb9bb31a471d |
    | ea1782fb-7489-4af3-8443-7290a48569f3 | pek_test_env_02_network |                                      |
    | f5e98168-3b35-4ef3-94ab-6bc113087554 | external_om             | 9d6f485f-7741-4c96-ac41-6c00744c60db |
    | f76ee0da-6944-44d4-b999-bdd4e3800c10 | external_api            | 9ab7e8de-2cb3-42bc-be70-cc37621f9ef9 |
    +--------------------------------------+-------------------------+--------------------------------------+


    
