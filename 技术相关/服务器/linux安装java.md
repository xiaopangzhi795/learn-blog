# linux安装java

## centos
- 查询版本

```
yum search java |grep jdk
```

- 安装

```
yum install java-1.8.0-openjdk-src.aarch64
```

- 查看版本号

```
 java -version
```

- 查看安装目录

```
find / -name 'java'
```