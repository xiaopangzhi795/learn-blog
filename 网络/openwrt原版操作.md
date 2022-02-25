# openwrt 原版操作流程

## 设备描述
硬件：树莓派 4B，路由器一个，mac电脑

## 下载
- balenaetcher
https://www.balena.io/etcher/

- 固件（清华大学下载源）
https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/21.02.1/targets/bcm27xx/bcm2711/openwrt-21.02.1-bcm27xx-bcm2711-rpi-4-ext4-factory.img.gz

## 刷固件
- 打开balenaEtcher
- 点击「Flash from file」
- 选择解压好的「openwrt-bcm27xx-bcm2711-rpi-4-ext4-factory.img」
- 点击「Select target」，选择闪存卡，注意看容量对不对，请勿选择本机硬盘
- 点击「Flash!」
- 成功后把闪存卡插入树莓派，树莓派插电后红灯常亮表示正常

## 登录

1. 使用原路由器的lan口连接树莓派
2. 将路由器的ip设置为192.168.1.2
3. 连接路由器发射出来的wifi，访问192.168.1.1，用户名root，密码password，登录openwrt
4. 将openwrt的network -> interfaces -> lan 的ipv4接口改为路由器原本的网段，随便找一个没人用的ip，记下来，我的路由器的网段为10.168.1.1，我将openwrt改成了10.168.1.254
5. 将路由器的网络修正，改为原本的样子
6. 此时自己的电脑应该是可以上网的，如果不能上网，请检查自己的路由器配置，让路由器和电脑还有openwrt处于可以上网状态
7. 到此为止，登录openwrt已经OK了，下面就是对openwrt做一系列的个性操作


## 更换源
批量将源的下载地址改为清华镜像源
sed -i 's_downloads.openwrt.org_mirrors.tuna.tsinghua.edu.cn/openwrt_' /etc/opkg

## 中文界面
- 更新

opkg update

- 安装中文界面

opkg install luci-i18n-base-zh-cn

- 再次登录openwrt界面就是中文了

## 安装插件

### passWall

### smartDns

### 可道云

### docker

### syncthing