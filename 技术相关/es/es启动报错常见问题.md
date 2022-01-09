# ES安装失败常见问题

## 1.es启动时，killed启动失败
> 失败原因：内存不足
> 解决方案：更改jvm.option的配置，将配置改为128m

## 启动失败can not run elasticsearch as root
> 失败原因：不能使用root账户启动es
> 解决方案：创建新账户，并将es目录赋权给对应的账户

``` 
// 创建账户
adduser es
// 设置密码
passwd es
//赋权
chown es /opt/es/
//切换账户
su es
//启动es
./elasticsearch -d
```

