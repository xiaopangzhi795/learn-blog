# 拉取centos镜像

```
docker pull centos:centos7
```

# 启动容器

```
## 普通启动
docker run -id --name centos centos:centos:7

## 挂载路径

## 映射端口
### 将容器的10081端口映射到宿主机的8080端口
docker run -p 8080:10081 -itd --name server server:1 /bin/bash
### 将容器的10081端口映射到宿主机的随机端口
docker run -P 10081 -itd --name server server:1 /bin/bash
### 将容器的所有端口都映射(不推荐）
docker run -P -itd --name server server:1 /bin/bash
### 映射多个端口
docker run -p 8080:10081 -p 3306:3306 -itd --name server server:1 /bin/bash
### 映射端口到指定ip的指定端口
docker run -p 127.0.0.1:8080:10081 -itd --name server server:1 /bin/bash
### 映射端口到指定ip的随机端口
docker run -p 127.0.0.1::10081 -itd --name server server:1 /bin/bash
### 指定通信协议
docker run -p 8080:10081/udp -itd --name server server:1 /bin/bash


                
## 查看容器端口映射
docker port 03fc5957887e
## 查看容器内部网络和ip地址
docker inspect 03fc5957887e
                
## 删除容器和镜像
#!/bin/zsh
echo 'stop ' $1
docker stop $1
echo 'rm' $1
docker rm $1
echo 'rm ' $2
docker rmi $2
```

# 自定义配置
```
## 更新&清除缓存
yum check-update
yum update
yum clean all

## 安装open jdk
yum search java
yum install java-1.8.0-openjdk.x86_64

## 安装vim
yum install vim

## 安装net-tool
yum install net-tools
```

# 导出为镜像
```
## export & import 
docker export 895c440025ca > server.tar
docker import - server < server.tar

## save & load
## 将容器保存为文件
docker save 895c440025ca > server.tar
## 将多个镜像打包成一个文件
docker save -o centos:7 nacos
## 加载镜像
docker load < server.tar
```

## 差异点
- export导出的镜像比save小
- import可以重新命名，load不能重命名
- export 不支持多个镜像打包成一个，save支持
- export（import导入）没有镜像的历史记录和元数据信息，近保存容器的快照状态，无法回滚。save（load导入）保存的镜像，可以回滚到之前的层。
- export：主要用于制作基础镜像，导出为一个镜像，发给其他人使用，作为基础的开发环境。
- save：编排多个镜像，比如目标服务器不能链接外网，可以使用save将用到的镜像打个包，拷贝到服
务器使用load载入

# dockerfile
```
FROM server:2

RUN yum install -y net-tools

USER admin

ARG APP_NAME=geek-ksp
ARG BASE_PATH=/home/admin/app

ENV APP_NAME=${APP_NAME}
ENV APP_ENVIRONMENT=testing
ENV APP_HOME=${BASE_PATH}/${APP_NAME}
ENV DEBUG_ENABLE=true

ENV BASE_PATH=${BASE_PATH}
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.322.b06-1.el7_9.x86_64/jre

# RUN yum check-update -y
# RUN yum update
# RUN yum clean-all -y
# RUN yum install -y java-1.8.0-openjdk.x86_64
# RUN yum install -y vim


RUN mkdir -p ${APP_HOME}
RUN mkdir -p ${APP_HOME}/bin
RUN mkdir -p ${APP_HOME}/config
RUN mkdir -p ${APP_HOME}/target
RUN mkdir -p ${APP_HOME}/logs
RUN mkdir -p ${APP_HOME}/logs/java

COPY ${APP_NAME}.jar ${APP_HOME}/target/${APP_NAME}.jar
COPY start.sh ${APP_HOME}/bin/start.sh
COPY ./bin/* ${APP_HOME}/bin

EXPOSE 10081

# ENTRYPOINT ["sh", "-c" ,"${APP_HOME}/bin/appctl"]
```

# 检查项目启动
```

#!/bin/sh

times=3600
status=0
echo "check port"
for e in $(seq $times); do
        sleep 1

        ret=`netstat -tunl|grep -c ":${JAVA_PORT}"`
        if [ $ret -gt 0 ]; then
                status=1
                break
        else
                echo -n -e "\r          -- check JAVA_PORT:${JAVA_PORT} cost `expr $e` seconds."
        fi
done
echo ""
if [ $status -eq 0 ]; then
        echo "                  -- JAVA_PORT:${JAVA_PORT} check failed."
        return 10000
else
        echo "                  -- JAVA_PORT:${JAVA_PORT} check success."
fi
echo ""
```

# 启动脚本
```
#!/bin/bash

PROG_NAME=$0
ACTION=$1
echo "ACTION: $ACTION"

usage() {
	echo "Usage: $PROG_NAME {start|stop|online|offline|pubstart|restart|deploy}"
	exit 2 # bad user
}

#usage

source "${APP_HOME}/bin/setenv.sh"

EXPLODED_TARGET="${APP_HOME}/target"
JAVA_OUT=${APP_HOME}/logs/java.log

startjava() {
	echo "step 1 -- start java process"
	
	touch ${APP_HOME}/logs/application.log
	touch ${APP_HOME}/logs/java/gc.log

	SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --startup.at=$(($(date +%s%N)/1000000))"
	echo "		-- JAVA_OPTS: ${JAVA_OPTS}"
	echo ""
	echo "		-- SPRINGBOOT_OPTS: ${SPRINGBOOT_OPTS}"
	echo ""

	nohup $JAVA_HOME/bin/java -jar $JAVA_OPTS ${APP_HOME}/target/${APP_NAME}.jar ${SPRINGBOOT_OPTS} &>${JAVA_OUT} &

	echo "step 2 -- check JAVA_PORT:${JAVA_PORT} for java application"
	. "${APP_HOME}/bin/preload.sh"
	
	echo "step 3 -- check health and online"
}

stopjava() {
	SLEEP=10
	FORCE=1

	echo "step 1 -- health check and offline"
	ret=`netstat -tunl|grep -c ":${JAVA_PORT}"`
	if [ $ret - eq 0 ]; then
		echo "Service not running. "
	else
		ret=`curl --max-time 2 -s "http://127.0.0.1:${JAVA_PORT}/health/off" -H "AUTH_CPASS:true"`
	
		if [ "$ret" == "off" ]; then
			for i in `seq 10`; do
				sleep 1
				echo -n -s "\r		-- waiting offline cost $i seconds."
			done
			echo -n -e "\r		-- app health check success and offline success"
		else
			echo "		--	app health check faild"
		fi
	fi


	echo "step 2 -- stop java process"
	PID=`ps -ef|grep java|grep ${APP_NAME}|grep ${APP_NAME}.jar|grep -v appctl.sh|grep -v jbossctl |grep -v restart.sh |grep -v grep|awk '{print $2}'`
	kill -15 "$PID" >/dev/null 2>&1
	echo -n -e "\r			-kill java process, pid: $PID. "
	
	while [ $SLEEP -ge 0 ]; do
		kill -0 "$PID" >/dev/null 2>&1
		if [ $? -gt 0 ]; then
			echo "Service stopped."
			FORCE=0
			break
		fi
		echo -n -e "\r		-- stoping java left $SLEEP seconds."

		if [ $SLEEP -gt 0 ]; then
			sleep 1
		fi
		SLEEP=`expr $SLEEP - 1 `
	done

	KILL_SLEEP_INTERVAL=5
	if [ $FORCE -eq 1 ]; then
		echo -n -e "\r		-- force kill java process, pid: $PID."
		while [ $KILL_SLEEP_INTERVAL -ge 0 ]; do
			kill -0 "$PID" >/dev/null 2>&1
			if [ $? -gt 0 ]; then
				echo "Service stopped."
				break
			fi
			kill -9 $PID
			echo -n -e "\r		--sopting java left $KILL_SLEEP_INTERVAL seconds."
			if [ $KILL_SLEEP_INTERVAL -gt 0 ]; then
				sleep 1
			fi
			KILL_SLEEP_INTERVAL=`expr $KILL_SLEEP_INTERVAL -1 `
		done
		if [ $KILL_SLEEP_INTERVAL -le 0 ]; then
			echo "Service has not been killed completely yet. The process might be waiting on some system call or might be UNINTERRUPTIBLE."
		fi
	fi

}

start() {
	echo "[start] -- start java"
	startjava
}

stop() {
	echo "[stop] -- try to stop java"
	stopjava
}

echo "$ACTION .."

case "$ACTION" in
	start)
		start
	;;
	stop)
		stop
	;;
	*)
		echo "warning"
	;;
esac
```

# 环境变量
```

#!/bin/sh

## 系统端口
export JAVA_PORT=10081

LOGGER_PATH=${APP_HOME}/logs/java

JAVA_OPTS="-server"
CATALINA_OPTS="-Xms512M -Xmx512M"

## JAVA_OPTS
JAVA_OPTS="${JAVA_OPTS} -XX:InitialRAMPercentage=50.0 -XX:MinRAMPercentage=50.0 -XX:MaxRAMPercentage=75.0"

JAVA_OPTS="${JAVA_OPTS} -XX:+UseG1GC -XX:+UseStringDeduplication"
JAVA_OPTS="${JAVA_OPTS} -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=1024m"
JAVA_OPTS="${JAVA_OPTS} -XX:MaxDirectMemorySize=1024m"
JAVA_OPTS="${JAVA_OPTS} -XX:+ExplicitGCInvokesConcurrent -Dsun.rmi.dgc.server.gcInterval=2592000000 -Dsun.rmi.dgc.client.gcInterval=2592000000"
JAVA_OPTS="${JAVA_OPTS} -Xloggc:${LOGGER_PATH}/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
JAVA_OPTS="${JAVA_OPTS} -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOGGER_PATH}/java.hprof"
JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true"
JAVA_OPTS="${JAVA_OPTS} -Dsun.net.client.defaultConnectTimeout=10000"
JAVA_OPTS="${JAVA_OPTS} -Dsun.net.client.defaultReadTimeout=30000"
JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF-8"
JAVA_OPTS="${JAVA_OPTS} -Dproject.name=${APP_NAME}"


## spring boot opts
SPRINGBOOT_OPTS="--server.port=${JAVA_PORT}"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --spring.profiles.active=${APP_ENVIRONMENT}"
# SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --logging.config=${APP_HOME}/config/logback.xml"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --logging.file.home=${APP_HOME}/logs"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --logging.path=${APP_HOME}/logs"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --logging.file=${APP_HOME}/logs/application.log"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --spring.pid.file=${APP_HOME}/logs/application.pid"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --server.tomcat.accesslog.enabled=true"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --server.tomcat.accesslog.directory=${APP_HOME}/logs"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --server.tomcat.accesslog.buffered=false"
SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --server.tomcat.accesslog.pattern=combined"


if [ "${DEBUG_ENABLE}" == "true" ]; then
	JAVA_OPTS="${JAVA_OPTS} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"
	SPRINGBOOT_OPTS="${SPRINGBOOT_OPTS} --logging.level.root=DEBUG"
fi

export JAVA_OPTS
export CATALINA_OPTS
export SPRINGBOOT_OPTS
```

# 自动化构建脚本
## 构建脚本

```
#!/bin/sh
## 设置环境变量
source "./setenv.sh"
echo 'step 1 :action clone code.........'

## 打印环境变量
echo 'clone repositories is :' $APP_GIT_PATH
echo 'clone branch is :' $APP_GIT_BRANCH
echo 'app name is :' $APP_NAME

## 将代码拉到本地
echo $(git clone -b $APP_GIT_BRANCH $APP_GIT_PATH ./$APP_NAME)

## 进入代码库中
cd $APP_NAME

## 编译代码进行打包
echo 'step 2 :build app $APP_NAME'
echo $(mvn clean package -DskipTests -T 4C -q -s $SETTINGS_WY)

## 回到上层目录
cd ..

## 将构建好的包移动到外层
echo 'step 3 :copy jar'
mv $APP_NAME/build/$APP_NAME.jar ./$APP_NAME.jar

## 构建docker镜像
echo 'step 4 :docker pull image'
echo $(docker build -t centos:v2 .)

## 启动docker容器
echo 'step 5 :docker run'
echo $(docker run -itd -p 8080:10081 --name test centos:v2 /bin/bash)

## 构建完成，休眠十秒，等待应用启动
echo 'build success'
echo 'sleep 3s waiting app start'
echo $(sleep 3s)

## 休眠完成，使用curl测试应用是否启动成功
echo 'test curl'
echo $(curl 127.0.0.1:8080/test/hello)

## 清理空间，将代码和jar包都删掉
echo 'action clean'
echo 'clean code'
echo $(rm -rf ${APP_NAME})
echo 'clean jar'
echo $(rm -rf ${APP_NAME}.jar)

## 执行结束
echo 'over'
```

## 环境变量
```
#!/bin/base

APP_GIT_PATH="git@gitlab.alibaba-inc.com:wb-qzl779136/geek-ksp.git"
APP_NAME="geek-ksp"
APP_GIT_BRANCH="tem_220421"

export APP_GIT_PATH
export APP_NAME
export APP_GIT_BRANCH
```





