# gradle入门教程

## 安装

### 1. 官网下载gradle
官网地址：https://gradle.org/releases/
### 2. 配置环境变量
#### mac版
> 因为我安装了zsh，所以需要在zsh下面配置，可以根据自己的终端程序进行配置


```
cd ~/
vim .zshrc
export GRADLE_HOME=/Users/qian/opt/gradle-7.3.3
export PATH=$PATH:$GRADLE_HOME/bin

```

#### other
可以在/etc/profile下面配置

### 3. 环境变量生效

``` source .zshrc ```


## 常见问题

### gradle 如何引用maven打的包
```
repositories {
    mavenCentral()
    mavenLocal()
}
```
在仓库配置中，加入mavenLocal配置即可

### build.gradle->dependencies下面都有什么属性，分别什么意思
- implementation

对于使用了该部分的编译有效，当前项目有效，其他项目如依赖当前项目，其他项目访问使用时无效，即对当前有效，对外部无效。

- api
相比implementation，该方式不进行隔离。

- compile(已经被废弃)
日常编译和打包时有效。

- testCompile
单元测试代码和打包测试时有效。

- debugCompile
debug模式编译和debug打包时有效。

- releaseCompile
release模式编译和打包时有效。



### gradle 引用的包无法加载配置


### 如何统一管理版本号


### 如何定义父子项目

### 如何打包到本地


### 如何拉取私有仓库的包