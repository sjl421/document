## Install OpenAM on EC2

### environment information
| sowftware | version |
|-----------|---------|
| OpenAM | 5.5.1|
|JDK | OpenJDK 1.8.0 |
|Tomcat |7.0.82 |

### install step
1.edit hosts file

```
sudo vi /etc/hosts
127.0.0.1    localhost openam.example.com www.example.com
```

2.install apache httpd

```
sudo yum install httpd.x86_64 -y
```

3.edit httpd configure file

```
sudo vi /etc/httpd/conf/httpd.conf
grep 8000 /path/to/apache/conf/httpd.conf
Listen 8000
ServerName www.example.com:8000
```

4.restart apache httpd

```
sudo service httpd restart
```

5.install jdk

```
yum install java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64
alternatives --config java
There are 2 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
*  1           /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java
 + 2           /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java

Enter to keep the current selection[+], or type selection number: 2
```

6.set java environment variable

```
sudo vi cat /etc/profile.d/java.sh
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk.x86_64
export PATH=$JAVA_HOME/bin:$PATH 
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
source /etc/profile
```

7.validate java environment variable

```
java -version
openjdk version "1.8.0_151"
OpenJDK Runtime Environment (build 1.8.0_151-b12)
OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)

javac -version
javac 1.7.0_151
```

8.download apache tomcat 7 from its [download page](http://tomcat.apache.org/download-70.cgi)
9.extract the download

```
tar -zxvf apache-tomcat-7.0.82.tar.gz
mv apache-tomcat-7.0.82 /usr/local/tomcat7
chmod 755 /usr/local/tomcat7/bin/*.sh
```

10.download OpenAM .war file from [forgerock](http://www.forgerock.com/)
11.deploy the .war file in tomcat as openam.war

```
mv AM-5.5.1.war /usr/local/tomcat7/webapps/openam.war
```

12.start tomcat

```
/usr/local/tomcat7/bin/startup.sh
```

13.access the web application in a browser at http://openam.example.com:8080/openam/ to configure the application


