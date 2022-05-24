<a name="T8jpC"></a>
# npm所有命令介绍
[https://www.npmjs.cn/cli/access/](https://www.npmjs.cn/cli/access/)
<a name="VCfzL"></a>
# npm更新
```shell
# 测试是否安装
npm -v 
# 更新到最新版本
npm install npm@latest -g
# 更新到下一个版本
npm install npm@next -g


```
<a name="sL4fT"></a>
# 版本指定（下方通用）
```shell
# 安装最新版本
npm install lodash 
npm install lodash@latest

# 安装指定版本
npm install lodash@4.7.1
```
<a name="d0jkk"></a>
# 安装
```shell
# 本地安装
# demo : npm install lodash
npm install <package-name>
# 将包安装在生产环境 .. npm install lodash --save
npm install <package-name> --save
# 将包安装在开发/测试环境 .. npm install lodash --save-dev
npm install <package-name> --save-dev

# 全局安装
npm install -g jshint
```
<a name="CDgR0"></a>
# 初始化设置
```shell
# 作者邮箱
npm set init.author.email "xxxx@xxx.com"
# 作者昵称
npm set init.author name "xxx"
# 许可证
npm set init.license "xxx"

# 初始化项目,
## 如果当前路径有git信息，就会自动将git信息保存到package.json中
## 如果设置了上述信息，也会保存到package.json中
## 如果package.json中没有description字段，npm会使用当前路径下的README.md的第一行作为description描述。
npm init
npm init --yes


```
<a name="Pd0ny"></a>
# 依赖包更新
```shell
# 本地包
# 检查依赖包是否可以更新，使用该命令没有输出为最佳
npm outdated


# 更新依赖包
## 只更新到当前库中，不修改package.json
npm update
## 更新当前库，并更新package.json文件
npm update --save


# 全局包
# 检查依赖包是否可以更新，使用该命令没有输出为最佳
npm outdated -g --depth=0

npm update -g <package>
```
<a name="F6xua"></a>
# 卸载依赖包
```shell
# 本地包
# 卸载本地库中的包
npm uninstall lodash
# 卸载本地库中的包，并在package.json中移除依赖
npm uninstall --save lodash

# 全局包
npm uninstall -g jshint
```



# npm拓展命令

```shell
# 查看版本
npm -v
# 查看所有命令
npm help
# 查看某个命令的详细信息
npm help uninstall
# 查看各个命令的简单用法
npm l
# npm配置
npm config list -l
npm config get init.author.name
# 修改npm配置
npm config set init.author.name maomao
# 删除npm配置
npm config delete init.author.name

# npm搜索模块
npm search [模块名] [-g]
## 别名
find / s / se

```

