docker start <容器id> 启动容器
docker stop <容器id>  停止容器
docker restart <容器id>  重新启动容器
docker attach <容器id>  进入容器（该命令退出时会导致容器停止）
docker exec -it <容器id> /bin/bash 进入容器
docker ps  查看正在运行的容器
docker ps -a 查看所有的容器
docker rm -f <容器id>  删除容器

-i 交互式操作
-t 终端
docker run -itd --name test-centos-v1 centos /bin/bash  后台运行一个容器
docker run -it cenos /bin/bash 运行一个容器
docker run -it cenos:v1 /bin/bash 运行v1版本的容器
docker run -p 9000:8080 centos java -jar /home/app/docker.jar

docker export 42f4f3d0aad9 > centos_test_v1.tar  导出容器
cat centos_test_v1.tar | docker import - centos_test_v1  导入容器为镜像
docker import http://example.com/exampleimage.tgz centos_test_v2  导入容器为镜像

docker search nginx  查询镜像
docker images 列出所有镜像
docker pull nginx:v1 拉取v1版本的镜像
docker pull nginx  拉取镜像
docker rmi nginx:版本号  删除镜像

docker commit -m "提交信息" -a "作者" <镜像id> centosv2 提交镜像指定目标名为centosv2

docker tag <镜像ID> runoob/centos:dev 创建镜像标签，

docker login --username=xiaopangzhi795@icloud.com registry.cn-hangzhou.aliyuncs.com
docker logout registry.cn-hangzhou.aliyuncs.com

docker cp test.xml centos:/home/test/test.xml

## 启动一个容器，别名为 test-docker  映射8080端口到docker  挂载/user/Logs 目录到容器中的/logs目录  后台启动
docker run -itd --name test-docker -p 8080:8080 -v /user/logs:/logs/ centos /bin/bash


区间端口:





redis和mongodb的启动时,不能使用 -it 和 /bin/bash



# docker操作文件

```shell
docker exec myMysql bash -c "echo 'log-bin=/var/lib/mysql/mysql-bin' >> /etc/mysql/mysql.conf.d/mysqld.cnf"

docker exec myMysql bash -c "echo 'server-id=123454' >> /etc/mysql/mysql.conf.d/mysqld.cnf"

docker restart myMysql

```



