# 生成ssh秘钥
## mac生成系统ssh秘钥
- 进入系统账号目录
- ``` cd ``` 回车
- 进入 ssh 文件
- ``` cd .ssh ```
- 生成ssh秘钥
- ``` ssh-keygen ```
- 一路按回车
- 查看生成的以 pub 结尾的文件
- ``` cat id_rsa.pub ```
- 将内容复制出来

## github上面生成ssh秘钥
- 登录github
- 点击头像旁边小三角，选择settings
- 选择SSH and GPG keys

![Jietu20211224-220030](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20211224-220030.jpg)

- 将上面复制出来的key粘贴到框里面，点击 ``` ADD SSH key ```

![Jietu20211224-220702](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20211224-220702.jpg)
