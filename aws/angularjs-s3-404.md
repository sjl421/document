## 将angularjs的static html放在S3上，refresh browser cause 404 not found error reason：
因为当browser第一次打开时，s3上的所有angularjs都会加载到browser，browser会做一些跳转，所有的跳转都是在browser端做的，与server端没有关系，不会向server端发送任何request，angularjs也是前端的一种MVC框架。当跳转到另一个url时，refresh browser时，browser会向server发送request，这个时候url中path对应s3上的一个object，这个object是不存在的，这个path是angularjs跳转自定义的。browser url中的path与s3的object是一一对应的。

## 将angularjs的static html放在ec2上，启动httpd web server，httpd开启**mod_rewrite**,refresh browser不会造成404 not found error reason：
因为browser第一次打开访问的是index.html，这个index.html是整个angularjs的入口，他会将所有的angularjs都加载到browser端，angularjs在browser做任何跳转，都不会向server发送任何request，完全在browser端做。当browser跳转到另一个url时，refresh browser由于web server open mod rewrite feature，server端会把request rewrite到index.html，index.html相当程序的主入口（main函数），index.html会把所有的angularjs module重新加载，这个时候的跳转包含了所有的angularjs的module，所有不会出现404 not found

## httpd open **mod_rewrite** method:

[Deploying prod build to Apache 2](https://github.com/mgechev/angular-seed/wiki/Deploying-prod-build-to-Apache-2)