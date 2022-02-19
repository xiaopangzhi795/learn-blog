# 安装
## mac系统
### 下载刷镜像工具balenaetcher
- 下载地址
https://www.balena.io/etcher/

### 下载固件
- 下载地址
  https://openwrt.cc/releases/targets/bcm27xx/bcm2711/

- 下载内容：根据自己的硬件信息进行下载，我的是树莓派，下载的是immortalwrt-bcm27xx-bcm2711-rpi-4-ext4-factory.img.gz

### 刷固件
- 打开balenaEtcher
- 点击「Flash from file」
- 选择解压好的「openwrt-bcm27xx-bcm2711-rpi-4-ext4-factory.img」
- 点击「Select target」，选择闪存卡，注意看容量对不对，请勿选择本机硬盘
- 点击「Flash!」
- 成功后把闪存卡插入树莓派，树莓派插电后红灯常亮表示正常


# 配置

## 基本操作

### 连接上树莓派

- 断开树莓派的有线连接，电脑连接树莓派发射的 WIFI：OpenWrt
- 断开电脑的无线连接，用网线接入树莓派

### 树莓派默认路由器地址
IP 是 192.168.1.1，用户为 root，密码为 password

## 网络配置

### 接口配置
- 选择网络 - 接口 - LAN
- 协议：静态ip
- Ipv4地址： 设置一个和你路由器同一网段的地址，不要冲突~
- 子网掩码：默认255.255.255.0
- ipv4网关：设置你准备连接的上游路由器地址
- ipv4广播，dns等留空即可
- ipv6分配：禁用，其他的选项保持默认
- 第二块中的ipv6设置，全部禁用
  
![10426470-3b3808f1d9ce4e9a](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/10426470-3b3808f1d9ce4e9a.jpg?token=AJTG6CSMKNUOTRXFSYHFKGLCCDKKK)

![Jietu20220219-192646](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-192646.jpg?token=AJTG6CS72QIN6IFIFK3JSMLCCDKLI)

![Jietu20220219-192705](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-192705.jpg?token=AJTG6CX7KDMP2GZW6S4FGVLCCDKLM)

![Jietu20220219-192743](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-192743.jpg?token=AJTG6CXU52ZKHGRFUQW36LTCCDKLO)

![Jietu20220219-192815](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-192815.jpg?token=AJTG6CTPRSUFZGPGAAN666DCCDKLQ)

### WiFi配置（有坑，记得看一下）
- 切记只要一个WiFi，不要多个
- 工作频率：AC，auto即可
- 高级设置：国家代码- CN - china
- 模式：接入点AP
- 加密：WPA2-PSK

![Jietu20220219-19281522](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-19281522.jpg?token=AJTG6CUCUMXFY42RBGQXSIDCCDKYO)

![Jietu20220219-193009](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-193009.jpg?token=AJTG6CVAJHY3DDJ5UDNPW6DCCDKYG)

![Jietu20220219-193029](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-193029.jpg?token=AJTG6CSSUGH24LITC2S5RFDCCDKYI)

![Jietu20220219-193042](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-193042.jpg?token=AJTG6CVTVVXO63JLDTLOGS3CCDKYM)

### DHCP/DNS解析
- 基本设置：DNS转发，设置smartDns的服务，127.0.0.1#6053
  
![Jietu20220219-193411](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-193411.jpg?token=AJTG6CRRV6BAYRIZH3E6QC3CCDLD2)

### 防火墙设置
- 关闭所有防御
- 区域转发-lan口-勾选ip动态伪装

![Jietu20220219-193601](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-193601.jpg?token=AJTG6CXP3MWY57CUG6M45LDCCDLKE)

### 关闭所有的网络加速-Turbo ACC 网络加速设置
![Jietu20220219-194108](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-194108.jpg?token=AJTG6CTLZUOVFDBRG6B2G63CCDL2A)

## 服务配置

### passWall 翻墙

- 节点订阅 - 最下方 - 添加订阅
![Jietu20220219-194310](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-194310.jpg?token=AJTG6CXGF2D4SFBJWVBO6D3CCDMBK)

- 上方订阅配置 - 点击手动订阅

![Jietu20220219-194439](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-194439.jpg?token=AJTG6CX756NFHCWVC4SXJGTCCDMHG)

- 基本配置

![Jietu20220219-194653](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-194653.jpg?token=AJTG6CXQWQASQNP6ZAFCZQDCCDMSS)

![Jietu20220219-194709](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-194709.jpg?token=AJTG6CRXFXVW5VCHSMUMO5LCCDMSU)

![Jietu20220219-194721](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-194721.jpg?token=AJTG6CSAFHRXL2YDJ3TADFDCCDMSW)

- 自动切换

![Jietu20220219-194835](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-194835.jpg?token=AJTG6CXDHRF7M554QEIP4Q3CCDNF4)


### smart dns配置
- 本地端口：6053
- dns 配置
cn
223.5.5.5
53
udp

cn
180.76.76.76
53
udp
 
cn
114.114.114.114
53
udp
 
cn
101.226.4.6
53
udp
 
cn
119.29.29.29
53
udp
 
cn
1.2.4.8
53
udp
 
us
8.8.8.8
53
tcp
 
us
8.8.8.8
853
tls
 
us
https://dns.google/dns-query
default
https
 
us
9.9.9.9
853
tls
 
us
https://doh.opendns.com/dns-query
443
https
 
us
208.67.222.222
53
tcp
 
us
208.67.222.222
853
tls

- 路由器内网域名解析
  
address /openwrt.com/192.168.1.254
address /route.com/10.168.1.1

![Jietu20220219-195620](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-195620.jpg?token=AJTG6CVJZTCEYXBJ6IW37EDCCDNWS)

![Jietu20220219-195700](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/Jietu20220219-195700.jpg?token=AJTG6CTDPKQFUHGGZPZ6FITCCDNWU)