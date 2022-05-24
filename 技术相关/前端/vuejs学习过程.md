# 1. 项目构建

```shell
# 创建vue-ts项目  使用最新的vite进行构建项目， demo01为项目名字， -- 为npm7+版本必加的一个参数，--template为使用模板创建，模板名字是vue-ts，也可以自己定义
npm create vite@latest demo01 -- --template vue-ts

# 安装项目中的依赖到本地
npm i
## 或者
npm install

# 安装指定依赖到项目中
## 安装到生产环境
npm i vue -S
## 安装到开发环境
npm i less -D
## 安装到全局
npm i vite -g

# 卸载模块
## 查看项目依赖
npm ls
## 卸载指定依赖
npm un less

```

