> 参考原文：[https://www.123si.org/os/article/building-ikev2-vpn-with-strongswan-in-centos-7/](https://www.123si.org/os/article/building-ikev2-vpn-with-strongswan-in-centos-7/)

<a name="vB7MJ"></a>
# 1. 安装strongSwan
<a name="Sd2Ck"></a>
## 使用EPEL源安装strongSwan，应为EPEL包含strongSwan的最新版本，EPEL更新比较快，如果系统中没有，则执行下面的命令安装EPEL源
<a name="RUbZu"></a>
## 1.1 安装EPEL源（可选）
```json
yum -y install epel-release
```

<a name="N19S1"></a>
## 1.2 安装openssl（可选）
```json
yum -y install openssl
```

<a name="euot0"></a>
## 1.3 安装strongSwan（必须）
```json
yum -y install strongswan
```

<a name="sUFy5"></a>
## 1.4 设置开机启动
```json
systemctl enable strongswan
```
<a name="W4N2T"></a>
## 
<a name="ppVef"></a>
# 2. 创建证书
<a name="UD87g"></a>
## 2.1 创建CA根证书
<a name="tNUsl"></a>
### 2.1.1 创建一个私钥
```json
strongswan pki --gen --outform pem > ca.key.pem
```

<a name="o9s3m"></a>
### 2.1.2 基于这个私钥自己签一个CA根证书
```json
strongswan pki --self --in ca.key.pem --dn "C=CN, O=123si, CN=123si StrongSwan CA" --ca --lifetime 3650 --outform pem > ca.cert.pem
```
<a name="TnAVA"></a>
### 2.1.3 参数简介
| 参数 | 描述 |
| --- | --- |
| --self | 表示自签证书 |
| --in | 是输入的私钥 |
| --dn | 是判别名 |
| C | 表示国家名，同样还有ST 州/省名字， L 地区名， STREET(全大写) 街道名 |
| O | 组织名称 |
| CN | 友好显示的通用名 |
| --ca | 表示生成CA根证书 |
| --lifetime | 有效期，单位是天 |


<a name="pJJ4F"></a>
## 2.2 创建服务端证书
<a name="R7Kyk"></a>
### 2.2.1 创建一个私钥
```json
strongswan pki --gen --outform pem > server.key.pem
```

<a name="LHQPh"></a>
### 2.2.2 用刚才自签的CA证书给自己发一个服务器证书
```json
##用私钥创建公钥
strongswan pki --pub --in server.key.pem --outform pem > server.pub.pem

# 用刚创建的公钥， 创建服务器证书
strongswan pki --issue --lifetime 3650 --cacert ca.cert.pem --cakey ca.key.pem --in server.pub.pem --dn "C=CN, O=123si, CN=39.105.18.85" --san="39.105.18.85" --flag serverAuth --flag ikeIntermediate --outform pem > server.cert.pem
```

<a name="JAJPU"></a>
### 2.2.3 参数介绍
| 参数 | 描述 |
| --- | --- |
| `--issue`，`--cacert`，`--cakey` | 就是表明要用刚才自签的CA证书来签这个服务器证书。 |
| `--dn`，`--san`，`--flag` | 是一些客户端方面的特殊要求<br />- ios客户端要求CN也就是通用名必须是你的服务器的URL或者IP地址<br />- Windows 7 不但要求了上面，还要求必须显示说明这个服务器证书的用途（用户与服务器进行认证），`--flag serverAuth`<br />- 非IOS的MAC OS X要求了“IP 安全网络密钥互换居间（IP Security IKE Intermediate）“这种增强型密钥用法（EKU）， `--flag ikeIntermediate`<br />- 安卓和IOS都要求服务器别名（serverAltName）就是服务器的URL或IP地址， `--san`<br /> |

<a name="ZLmtk"></a>
## 2.3. 创建客户端证书
<a name="Sl31k"></a>
### 2.3.1 创建一个私钥
```json
strongswan pki --gen --ourform pem > client.key.pem
```
<a name="d7nLd"></a>
### 2.3.2 用刚才自签的CA证书来签客户端证书
```json
# 用私钥创建公钥
strongswan pki --pub --in client.key.pem --outform > client.pub.pem

# 用刚创建的公钥，创建客户端证书
strongswan pki --issue --lifetime 3650 --cacert ca.cert.pem --cakey ca.key.pem --in client.pub.pem --dn "C=CN, O=123si, CN=39.105.18.85" --outform pem > client.cert.pem
```
<a name="y4WbU"></a>
## 2.4 打包证书为pkcs12
```json
openssl pkcs12 -export -inkey client.key.pem -in client.cert.pem -name "123si StrongSwan Client Cert" -certfile ca.cert.pem -caname "123si StrongSwan CA" -out client.cert.p12
```
执行命令后，会提示输入两次密码，这个密码是在导入证书到其他系统时需要验证的。没有这个密码，就算别人拿到了证书也没办法使用

<a name="DGJEE"></a>
# 3. 安装证书
```json
cp -r ca.key.pem /etc/strongswan/ipsec.d/private/
cp -r ca.cert.pem /etc/strongswan/ipsec.d/cacerts/
cp -r server.cert.pem /etc/strongswan/ipsec.d/certs/
cp -r server.pub.pem /etc/strongswan/ipsec.d/certs/
cp -r server.key.pem /etc/strongswan/ipsec.d/private/
cp -r client.cert.pem /etc/strongswan/ipsec.d/certs/
cp -r client.key.pem /etc/strongswan/ipsec.d/private/
```
<a name="IVoD8"></a>
# 4. 配置VPN
<a name="tTVsQ"></a>
## 4.1 修改主配置文件 ipsec.conf

配置文件 ipsec.conf 官方介绍链接  [ipsec.conf: conn Reference](https://wiki.strongswan.org/projects/strongswan/wiki/ConnSection)<br />编辑配置文件
```json
vim /etc/strongswan/ipsec.conf
```

<a name="sFfq3"></a>
### 参考配置
```json
# ipsec.conf - strongSwan IPsec configuration file
# basic configuration
config setup
    # strictcrlpolicy=yes
    uniqueids = never
# Add connections here.
# Sample VPN connections
#conn sample-self-signed
#      leftsubnet=10.1.0.0/16
#      leftcert=selfCert.der
#      leftsendcert=never
#      right=192.168.0.2
#      rightsubnet=10.2.0.0/16
#      rightcert=peerCert.der
#      auto=start
#conn sample-with-ca-cert
#      leftsubnet=10.1.0.0/16
#      leftcert=myCert.pem
#      right=192.168.0.2
#      rightsubnet=10.2.0.0/16
#      rightid="C=CH, O=Linux strongSwan CN=peer name"
#      auto=start
conn %default
    compress = yes
    esp = aes256-sha256,aes256-sha1,3des-sha1!
    ike = aes256-sha256-modp2048,aes256-sha1-modp2048,aes128-sha1-modp2048,3des-sha1-modp2048,aes256-sha256-modp1024,aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!
    keyexchange = ike
    keyingtries = 1
    leftdns = 8.8.8.8,8.8.4.4
    rightdns = 8.8.8.8,8.8.4.4
conn IKEv2-BASE
    # 服务器端根证书 DN 名称
    leftca = "C=CN, O=123si, CN=123si StrongSwan CA"
    # 是否发送服务器证书到客户端
    leftsendcert = always
    # 客户端不发送证书
    rightsendcert = never
conn IKEv2-EAP
    leftca = "C=CN, O=123si, CN=123si StrongSwan CA"
    leftcert = server.cert.pem
    leftsendcert = always
    rightsendcert = never
    leftid = 48.85.166.86
    left = %any
    right = %any
    leftauth = pubkey
    rightauth = eap-mschapv2
    leftfirewall = yes
    leftsubnet = 0.0.0.0/0
    rightsourceip = 10.1.0.0/16
    fragmentation = yes
    rekey = no
    eap_identity = %any
    auto = add
```

<a name="fZxKt"></a>
## 4.2 修改DNS配置
strongSwan v5.1.2 之后，所有插件配置都分散在 /etc/strongswan/strongswan.d/ 目录中<br />编辑配置文件：
```json
vim /etc/strongswan/strongswan.d/charon.conf
```
增加DNS配置。 去掉dns1和dns2签名的#
```json
# Options for the charon IKE daemon.
charon {
    # Accept unencrypted ID and HASH payloads in IKEv1 Main Mode.
    # accept_unencrypted_mainmode_messages = no
    # Maximum number of half-open IKE_SAs for a single peer IP.
    # block_threshold = 5
    # Whether Certificate Revocation Lists (CRLs) fetched via HTTP or LDAP
    # should be saved under a unique file name derived from the public key of
    # the Certification Authority (CA) to /etc/ipsec.d/crls (stroke) or
    # /etc/swanctl/x509crl (vici), respectively.
    # cache_crls = no
    # Whether relations in validated certificate chains should be cached in
    # memory.
    # cert_cache = yes
    # Send Cisco Unity vendor ID payload (IKEv1 only).
    # cisco_unity = no
    # Close the IKE_SA if setup of the CHILD_SA along with IKE_AUTH failed.
    # close_ike_on_child_failure = no
    # Number of half-open IKE_SAs that activate the cookie mechanism.
    # cookie_threshold = 10
    # Delete CHILD_SAs right after they got successfully rekeyed (IKEv1 only).
    # delete_rekeyed = no
    # Delay in seconds until inbound IPsec SAs are deleted after rekeyings
    # (IKEv2 only).
    # delete_rekeyed_delay = 5
    # Use ANSI X9.42 DH exponent size or optimum size matched to cryptographic
    # strength.
    # dh_exponent_ansi_x9_42 = yes
    # Use RTLD_NOW with dlopen when loading plugins and IMV/IMCs to reveal
    # missing symbols immediately.
    # dlopen_use_rtld_now = no
    # DNS server assigned to peer via configuration payload (CP).
    # Windows 公用 DNS
    dns1 = 8.8.8.8
    # DNS server assigned to peer via configuration payload (CP).
    # Windows 公用 DNS
    dns2 = 8.8.4.4
    # Enable Denial of Service protection using cookies and aggressiveness
    # checks.
    # dos_protection = yes
    # Compliance with the errata for RFC 4753.
    # ecp_x_coordinate_only = yes
    # Free objects during authentication (might conflict with plugins).
    # flush_auth_cfg = no
    # Whether to follow IKEv2 redirects (RFC 5685).
    # follow_redirects = yes
    # Maximum size (complete IP datagram size in bytes) of a sent IKE fragment
    # when using proprietary IKEv1 or standardized IKEv2 fragmentation, defaults
    # to 1280 (use 0 for address family specific default values, which uses a
    # lower value for IPv4).  If specified this limit is used for both IPv4 and
    # IPv6.
    # fragment_size = 1280
    # Name of the group the daemon changes to after startup.
    # group =
    # Timeout in seconds for connecting IKE_SAs (also see IKE_SA_INIT DROPPING).
    # half_open_timeout = 30
    # Enable hash and URL support.
    # hash_and_url = no
    # Allow IKEv1 Aggressive Mode with pre-shared keys as responder.
    # i_dont_care_about_security_and_use_aggressive_mode_psk = no
    # Whether to ignore the traffic selectors from the kernel's acquire events
    # for IKEv2 connections (they are not used for IKEv1).
    # ignore_acquire_ts = no
    # A space-separated list of routing tables to be excluded from route
    # lookups.
    # ignore_routing_tables =
    # Maximum number of IKE_SAs that can be established at the same time before
    # new connection attempts are blocked.
    # ikesa_limit = 0
    # Number of exclusively locked segments in the hash table.
    # ikesa_table_segments = 1
    # Size of the IKE_SA hash table.
    # ikesa_table_size = 1
    # Whether to close IKE_SA if the only CHILD_SA closed due to inactivity.
    # inactivity_close_ike = no
    # Limit new connections based on the current number of half open IKE_SAs,
    # see IKE_SA_INIT DROPPING in strongswan.conf(5).
    # init_limit_half_open = 0
    # Limit new connections based on the number of queued jobs.
    # init_limit_job_load = 0
    # Causes charon daemon to ignore IKE initiation requests.
    # initiator_only = no
    # Install routes into a separate routing table for established IPsec
    # tunnels.
    # install_routes = yes
    # Install virtual IP addresses.
    # install_virtual_ip = yes
    # The name of the interface on which virtual IP addresses should be
    # installed.
    # install_virtual_ip_on =
    # Check daemon, libstrongswan and plugin integrity at startup.
    # integrity_test = no
    # A comma-separated list of network interfaces that should be ignored, if
    # interfaces_use is specified this option has no effect.
    # interfaces_ignore =
    # A comma-separated list of network interfaces that should be used by
    # charon. All other interfaces are ignored.
    # interfaces_use =
    # NAT keep alive interval.
    # keep_alive = 20s
    # Plugins to load in the IKE daemon charon.
    # load =
    # Determine plugins to load via each plugin's load option.
    # load_modular = no
    # Initiate IKEv2 reauthentication with a make-before-break scheme.
    # make_before_break = no
    # Maximum number of IKEv1 phase 2 exchanges per IKE_SA to keep state about
    # and track concurrently.
    # max_ikev1_exchanges = 3
    # Maximum packet size accepted by charon.
    # max_packet = 10000
    # Enable multiple authentication exchanges (RFC 4739).
    # multiple_authentication = yes
    # WINS servers assigned to peer via configuration payload (CP).
    # nbns1 =
    # WINS servers assigned to peer via configuration payload (CP).
    # nbns2 =
    # UDP port used locally. If set to 0 a random port will be allocated.
    # port = 500
    # UDP port used locally in case of NAT-T. If set to 0 a random port will be
    # allocated.  Has to be different from charon.port, otherwise a random port
    # will be allocated.
    # port_nat_t = 4500
    # Whether to prefer updating SAs to the path with the best route.
    # prefer_best_path = no
    # Prefer locally configured proposals for IKE/IPsec over supplied ones as
    # responder (disabling this can avoid keying retries due to
    # INVALID_KE_PAYLOAD notifies).
    # prefer_configured_proposals = yes
    # By default public IPv6 addresses are preferred over temporary ones (RFC
    # 4941), to make connections more stable. Enable this option to reverse
    # this.
    # prefer_temporary_addrs = no
    # Process RTM_NEWROUTE and RTM_DELROUTE events.
    # process_route = yes
    # Delay in ms for receiving packets, to simulate larger RTT.
    # receive_delay = 0
    # Delay request messages.
    # receive_delay_request = yes
    # Delay response messages.
    # receive_delay_response = yes
    # Specific IKEv2 message type to delay, 0 for any.
    # receive_delay_type = 0
    # Size of the AH/ESP replay window, in packets.
    # replay_window = 32
    # Base to use for calculating exponential back off, see IKEv2 RETRANSMISSION
    # in strongswan.conf(5).
    # retransmit_base = 1.8
    # Maximum jitter in percent to apply randomly to calculated retransmission
    # timeout (0 to disable).
    # retransmit_jitter = 0
    # Upper limit in seconds for calculated retransmission timeout (0 to
    # disable).
    # retransmit_limit = 0
    # Timeout in seconds before sending first retransmit.
    # retransmit_timeout = 4.0
    # Number of times to retransmit a packet before giving up.
    # retransmit_tries = 5
    # Interval in seconds to use when retrying to initiate an IKE_SA (e.g. if
    # DNS resolution failed), 0 to disable retries.
    # retry_initiate_interval = 0
    # Initiate CHILD_SA within existing IKE_SAs (always enabled for IKEv1).
    # reuse_ikesa = yes
    # Numerical routing table to install routes to.
    # routing_table =
    # Priority of the routing table.
    # routing_table_prio =
    # Whether to use RSA with PSS padding instead of PKCS#1 padding by default.
    # rsa_pss = no
    # Delay in ms for sending packets, to simulate larger RTT.
    # send_delay = 0
    # Delay request messages.
    # send_delay_request = yes
    # Delay response messages.
    # send_delay_response = yes
    # Specific IKEv2 message type to delay, 0 for any.
    # send_delay_type = 0
    # Send strongSwan vendor ID payload
    # send_vendor_id = no
    # Whether to enable Signature Authentication as per RFC 7427.
    # signature_authentication = yes
    # Whether to enable constraints against IKEv2 signature schemes.
    # signature_authentication_constraints = yes
    # The upper limit for SPIs requested from the kernel for IPsec SAs.
    # spi_max = 0xcfffffff
    # The lower limit for SPIs requested from the kernel for IPsec SAs.
    # spi_min = 0xc0000000
    # Number of worker threads in charon.
    # threads = 16
    # Name of the user the daemon changes to after startup.
    # user =
    crypto_test {
        # Benchmark crypto algorithms and order them by efficiency.
        # bench = no
        # Buffer size used for crypto benchmark.
        # bench_size = 1024
        # Time in ms during which crypto algorithm performance is measured.
        # bench_time = 50
        # Test crypto algorithms during registration (requires test vectors
        # provided by the test-vectors plugin).
        # on_add = no
        # Test crypto algorithms on each crypto primitive instantiation.
        # on_create = no
        # Strictly require at least one test vector to enable an algorithm.
        # required = no
        # Whether to test RNG with TRUE quality; requires a lot of entropy.
        # rng_true = no
    }
    host_resolver {
        # Maximum number of concurrent resolver threads (they are terminated if
        # unused).
        # max_threads = 3
        # Minimum number of resolver threads to keep around.
        # min_threads = 0
    }
    leak_detective {
        # Includes source file names and line numbers in leak detective output.
        # detailed = yes
        # Threshold in bytes for leaks to be reported (0 to report all).
        # usage_threshold = 10240
        # Threshold in number of allocations for leaks to be reported (0 to
        # report all).
        # usage_threshold_count = 0
    }
    processor {
        # Section to configure the number of reserved threads per priority class
        # see JOB PRIORITY MANAGEMENT in strongswan.conf(5).
        priority_threads {
        }
    }
    # Section containing a list of scripts (name = path) that are executed when
    # the daemon is started.
    start-scripts {
    }
    # Section containing a list of scripts (name = path) that are executed when
    # the daemon is terminated.
    stop-scripts {
    }
    tls {
        # List of TLS encryption ciphers.
        # cipher =
        # List of TLS key exchange methods.
        # key_exchange =
        # List of TLS MAC algorithms.
        # mac =
        # List of TLS cipher suites.
        # suites =
    }
    x509 {
        # Discard certificates with unsupported or unknown critical extensions.
        # enforce_critical = yes
    }
}
```

<a name="fZwzO"></a>
## 4.3 配置用户名和密码
<a name="mFxBZ"></a>
### 编辑配置文件
```shell
vim /etc/strongswan/ipsec.secrets
```
<a name="xnRHx"></a>
### 添加用户名和密码
```shell
# ipsec.secrets - strongSwan IPsec secrets file
# 使用证书验证时的服务器端私钥
# 格式 : RSA <private key file> [ <passphrase> | %prompt ]
: RSA server.key.pem
# 使用预设加密密钥, 越长越好
# 格式 [ <id selectors> ] : PSK <secret>
%any %any : PSK "abcdef123456"
# EAP 方式, 格式同 psk 相同
UserName1 %any : EAP "UserPassword1"
UserName2 %any : EAP "UserPassword2"
# XAUTH 方式, 只适用于 IKEv1
# 格式 [ <servername> ] <username> : XAUTH "<password>"
UserName1 %any : XAUTH "UserPassword1"
UserName2 %any : XAUTH "UserPassword2"
```

<a name="Njr9R"></a>
## 4.4 开启内核转发
<a name="H9sfa"></a>
### 编辑配置文件
```shell
vim /etc/sysctl.conf
```
<a name="rXOMZ"></a>
### 添加配置方式一
```shell
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```
<a name="TgmKx"></a>
### 添加配置方式二
```shell
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
```
<a name="Cxgze"></a>
### 重新加载系统参数，使上面配置生效
```shell
sysctl -p
```

<a name="UcsGe"></a>
# 5 配置防火墙（如果是阿里云服务器，可以不配置，因为防火墙都没有启动，需要在阿里云后台管理配置防火墙的udp端口。500&4500）
<a name="cahUg"></a>
## 配置Centos 7 系统默认防火墙  FirewallD
注意，一下命令没有指定 --zone=public 参数，都是针对默认区域 public

<a name="k0zTm"></a>
## 5.1 为区域添加服务
```shell
firewall-cmd --permanent --add-service="ipsec"
```

<a name="XWSr3"></a>
## 5.2 允许AH 和 ESP 身份验证协议 和 加密协议通过防火墙
```shell
# ESP (the encrypted data packets)
firewall-cmd --permanent --add-rich-rule='rule protocol value="esp" accept'
# AH (authenticated headers)
firewall-cmd --permanent --add-rich-rule='rule protocol value="ah" accept'
```

<a name="FeiTc"></a>
## 5.3 开放 500 和 4500 端口（阿里云服务器，请在后台进行配置这两个端口）
```shell
# IKE  (security associations)
firewall-cmd --permanent --add-port=500/udp
# IKE NAT Traversal (IPsec between natted devices)
firewall-cmd --permanent --add-port=4500/udp
```

<a name="jhNdJ"></a>
## 5.4 启用IP伪装
```shell
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.1.0.0/16" masquerade'
```
<a name="rElnK"></a>
## 5.5 添加nat转发
```shell
firewall-cmd --permanen --add-rich-rule='rule family="ipv4" source address="10.1.0.0/16" forward-port port="4500" protocol="udp" to-port="4500"'
firewall-cmd --permanen --add-rich-rule='rule family="ipv4" source address="10.1.0.0/16" forward-port port="500" protocol="udp" to-port="500"'
```
<a name="HnIRz"></a>
## 5.6 重新加载防火墙配置
```shell
firewall-cmd --reload
```
<a name="Q5WqN"></a>
## 5.7 显示所有公共区域（public）
```shell
firewall-cmd --list-all
```
<a name="pvypK"></a>
# 6. strongSwan 服务操作
<a name="ToPR5"></a>
## 6.1 strongswan 自身命令
```shell
# 停止服务
strongswan stop

# 查看是否连接了客户端
strongswan status

# 查看帮助命令
strongswan --help
```
<a name="sZnNr"></a>
## 6.2 使用systemctl 命令
```shell
# 设置开机启动 strongswan 服务
systemctl enable strongswan 

# 启动服务
systemctl start strongswan

# 停止服务
systemctl stop strongswan

# 重启服务
systemctl restart strongswan

# 查看服务状态
systemctl status strongswan
```

<a name="rrTVc"></a>
## 注意，如果使用strongswan restart 命令重启strongSwan后，再用 systemctl status strongswan 命令得不到正确的运行状态

<a name="Lc0IA"></a>
# 到此服务端配置已完成

<a name="k8JH4"></a>
# 7. 客户端配置
<a name="nISrD"></a>
## 7.1 IOS系统
先导入CA证书，将之前创建的 ca.cert.pem 用ftp导出， 写邮件以附件的方式发到邮箱，在IOS浏览器登陆邮箱，下载附件，安装CA证书。
<a name="renEQ"></a>
### 7.1.1 使用IKEv2 + EAP 认证
找到手机上“设置 - VPN - 添加配置” ， 选IKEv2

- 描述：随便写
- 服务器：填写URL或者IP
- 远程ID：ipsec.conf 中的 leftid
- 用户鉴定：用户名
- 用户名：EAP项用户名
- 密码： EAP项密码

<a name="DFJRX"></a>
### 7.1.2 使用IKEv2 + 客户端证书 认证
把之前的.p12证书（里面包含CA证书）发到邮箱在手机上打开。导入到手机（需要之前设置的证书密码）<br />找到手机上 “ 设置 - VPN - 添加配置” ， 选IKEv2

- 描述：随便填
- 服务器：URL或IP
- 远程ID：ipsec.conf 中的 leftid
- 用户鉴定： 证书
- 证书：选择安装完的客户端证书

<a name="prUEV"></a>
### 7.1.3 使用IKEv2 + 预设密码认证
找到手机上 “ 设置 - VPN - 添加配置” ， 选IKEv2

- 描述：随便填
- 服务器：URL或IP
- 远程ID：ipsec.conf 中的 leftid
- 用户鉴定： 无
- 使用证书： 关
- 密钥： PSK 项密码

<a name="vuh34"></a>
## 7.2 windows 10
导入证书：

- 将 CA 根证书 ca.cert.pem 重命名为 ca.cert.crt；
- 双击 ca.cert.crt 开始安装证书；
- 点击安装证书；
- “存储位置”选择“本地计算机”，下一步；
- 选择“将所有的证书都放入下列存储区”，点浏览，选择“受信任的根证书颁发机构”，确定，下一步，完成；

建立连接：

- “控制面板”-“网络和共享中心”-“设置新的连接或网络”-“连接到工作区”-“使用我的 Internet 连接”；
- Internet 地址写服务器 IP 或 URL；
- 描述随便写；
- 用户名密码写之前配置的 EAP 的那个；
- 确定；
- 转到 控制面板网络和 Internet 网络连接；
- 在新建的 VPN 连接上右键属性然后切换到“安全”选项卡；
- VPN 类型选 IKEv2 ；
- 数据加密选“需要加密”；
- 身份认证这里需要说一下，如果想要使用 EAP 认证的话就选择“Microsoft : 安全密码(EAP-MSCHAP v2)”；想要使用私人证书认证的话就选择“使用计算机证书”；
- 再切换到“网络”选项卡，双击“Internet 协议版本 4”以打开属性窗口，这里说一下，如果你使用的是老版本的 Win10，可能会打不开属性窗口，这是已知的 Bug，升级最新版本即可解决；
- 点击“高级”按钮，勾选“在远程网络上使用默认网关”，确定退出；


<a name="jG8fH"></a>
## 7.3 Windows 7 导入证书略有不同

- 开始菜单搜索“cmd”，打开后输入 MMC（Microsoft 管理控制台）；
- “文件”-“添加/删除管理单元”，添加“证书”单元；
- 证书单元的弹出窗口中一定要选“计算机账户”，之后选“本地计算机”，确定；
- 在左边的“控制台根节点”下选择“证书”-“受信任的根证书颁发机构”-“证书”，右键“所有任务”-“导入”打开证书导入窗口；
- 选择 CA 证书 ca.cert.crt 导入即可；

_注意，千万不要双击 .p12 证书导入！因为那样会导入到当前用户而不是本机计算机中。_

<a name="RNlZV"></a>
# 8. 可能遇到的问题
<a name="YBsME"></a>
## 1. windows10 系统vpn能正常连接，但不能打开网页的情况
这与“VPN 连接”属性中的“接口跃点数”设置有关。该设置用于设置网络接口的优先级，使用 cmd 执行命令route print查看路由表，知道其他接口的跃点数后，我们只要将“VPN 连接”的“接口跃点数”设置低于它们就可以了。设置好后，网络请求会优先使用“VPN 连接”。

<a name="jrFlG"></a>
## 2. openssl 生成客户端证书时，unable to load certificates
如果完全按照流程走的，可能你的服务器不支持该中方式，请参考其他方式。请勿使用容器，需要直接使用宿主机。


<a name="mQYPm"></a>
# 附录
<a name="d7M5U"></a>
## 文件及其位置统一说明
<a name="RmLdq"></a>
### 安装程序

- epel-release	EPEL源
- openssl
- strongswan
<a name="ktTo3"></a>
### 文件说明

- /etc/strongswan/ipsec.d/	证书存放路径。key放在private目录下面，cert放在certs目录下面
- ipsec.conf	主配置文件。/etc/strongswan/ipsec.conf
- charon.conf		DNS配置文件。/etc/strongswan/strongswan.d/charon.conf
- ipsec.secrets	配置账号密码。/etc/strongswan/ipsec.secrets
- sysctl.conf		开启内核转发，系统配置文件。/etc/sysctl.conf
<a name="VC0hU"></a>
## ipsec 配置文件常用说明
```shell
config setup
    # 是否缓存证书吊销列表
    # <em>cachecrls = yes</em>
    # 是否严格执行证书吊销规则
    # strictcrlpolicy=yes
    # 如果同一个用户在不同的设备上重复登录，yes 断开旧连接，创建新连接；no 保持旧连接，并发送通知；never 同 no，但不发送通知。
    uniqueids=no
# 配置根证书，如果不使用证书吊销列表，可以不用这段。命名为 %default 所有配置节都会继承它
# ca %default
    # 证书吊销列表 URL，可以是 LDAP，HTTP，或文件路径
    # crluri = <uri>
# 定义连接项，命名为 %default 所有连接都会继承它
conn %default
    # 是否启用压缩，yes 表示如果支持压缩会启用
    compress = yes
    # 当意外断开后尝试的操作，hold，保持并重连直到超时
    dpdaction = hold
    # 意外断开后尝试重连时长
    dpddelay = 30s
    # 意外断开后超时时长，只对 IKEv1 起作用
    dpdtimeout = 60s
    # 闲置时长，超过后断开连接
    inactivity = 300s
    # 数据传输协议加密算法列表
    esp = aes256-sha256,aes256-sha1,3des-sha1!
    # 密钥交换协议加密算法列表
    ike = aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!
    # 默认的密钥交换算法，ike 为自动，优先使用 IKEv2
    keyexchange = ike
    # 服务端公网 IP，可以是魔术字 %any，表示从本地 IP 地址表中取
    left = %any
    # 客户端 IP，同上
    right = %any
    # 指定服务端与客户端的 DNS，多个用“,”分隔
    leftdns = 8.8.8.8,8.8.4.4
    rightdns = 8.8.8.8,8.8.4.4
    # 服务端用于 ike 认证时使用的端口，默认为 500，如果使用了 nat 转发，则使用 4500
    # leftikeport = <port>
    # 服务器端虚拟 IP 地址
    # leftsourceip = %config
    # 客户端虚拟 IP 段
    rightsourceip = 10.0.0.0/24
    # 服务器端子网，魔术字 0.0.0.0/0 。如果为客户端分配1:q虚拟 IP 地址的话，那表示之后要做 iptables 转发，那么服务器端就必须是用魔术字
    leftsubnet = 0.0.0.0/0
    # rightsubnet = <ip subnet>[[<proto/port>]][,...]
conn IKEv2-BASE
    # 服务器端根证书 DN 名称
    leftca = "C=CN, O=123si, CN=123si StrongSwan CA"
    # 服务器证书，可以是 PEM 或 DER 格式
    leftcert = server.cert.pem
    # 不指定客户端证书路径
    # rightcert = <path>
    # 指定服务器证书的公钥
    leftsigkey = server.pub.pem
    # rightsigkey = <raw public key> | <path to public key>
    # 是否发送服务器证书到客户端
    leftsendcert = always
    # 客户端不发送证书
    rightsendcert = never
    # 服务端认证方法，使用证书
    leftauth = pubkey
    # 客户端认证使用 EAP 扩展认证，貌似 eap-mschapv2 比较通用
    rightauth = eap-mschapv2
    # 服务端 ID，可以任意指定，默认为服务器证书的 subject，还可以是魔术字 %any，表示什么都行
    leftid = vpn.itnmg.net
    # 客户端 id，任意
    rightid = %any
# ios, mac os, win7+, linux
conn IKEv2-EAP
    also = IKEv2-BASE
    # 指定客户端 eap id
    eap_identity = %any
    # 不自动重置密钥
    rekey = no
    # 开启 IKE 消息分片
    fragmentation = yes
    # 当服务启动时，应该如何处理这个连接项。add 添加到连接表中。
    auto = add
```

<a name="uBePm"></a>
## 参考文档

- [strongSwan - 官网](https://www.strongswan.org/)
- [IPSEC VPN on Centos 7 with StrongSwan](https://raymii.org/s/tutorials/IPSEC_vpn_with_CentOS_7.html)
- [CentOS 7 配置 IPSec-IKEv2 VPN, 适用于 ios, mac os, windows, linux.](https://blog.itnmg.net/2015/04/03/centos7-ipsec-vpn/)
- [在阿里云 CentOS 7上使用strongswan搭建IKEv2 VPN](https://blog.csdn.net/wengzilai/article/details/78707134)
- [一键搭建适用于Ubuntu/CentOS的IKEV2/L2TP的VPN](https://github.com/quericy/one-key-ikev2-vpn)

<a name="IGDg5"></a>
## 其他开源VPN工具

- **Algo**
> Algo 是从下往上设计的，可以为需要互联网安全代理的商务旅客创建 VPN 专用网。它“只包括您所需要的最小化的软件”，这意味着为了简单而牺牲了可扩展性。Algo 是基于 StrongSwan 的，但是删除了所有您不需要的东西，这有另外一个好处，那就是去除了新手可能不会注意到的安全漏洞。
> 作为额外的奖励，它甚至可以屏蔽广告！
> Algo 只支持 IKEv2 协议和 Wireguard。因为对 IKEv2 的支持现在已经内置在大多数设备中，所以它不需要像 OpenVPN 这样的客户端应用程序。Algo 可以使用 Ansible 在 Ubuntu (首选选项)、Windows、RedHat、CentOS 和 FreeBSD 上部署。 使用 Ansible 可以自动化安装，它会根据您对一组简短的问题的回答来配置服务。卸载和重新部署也非常容易。
> Algo 可能是在本文中安装和部署最简单和最快的 VPN。它非常简洁，考虑周全。如果您不需要其他工具提供的高级功能，只需要一个安全代理，这是一个很好的选择。请注意，Algo 明确表示，它不是为了解除地理封锁或逃避审查，主要是为了加密。

- **Streisand**
> Streisand 可以使用一个命令安装在任何 Ubuntu 16.04 服务器上；这个过程大约需要 10 分钟。它支持 L2TP、OpenConnect、OpenSSH、OpenVPN、Shadowsocks、Stunnel、Tor bridge 和 WireGuard。根据您选择的协议，您可能需要安装客户端应用程序。
> 在很多方面，Streisand 与 Algo 相似，但是它提供了更多的协议和定制。这需要更多的工作来管理和维护，但也更加灵活。注意 Streisand 不支持 IKEv2。因为它的多功能性，我认为 Streisand 在某国和土耳其这样的地方绕过审查制度更有效，但是 Algo 的安装更容易和更快。
> 使用 Ansible 可以自动化安装，所以不需要太多的专业技术知识。通过向用户发送自定义生成的连接指令，包括服务器 SSL 证书的嵌入副本，可以轻松添加更多用户。
> 卸载 Streisand 是一个快速无痛的过程，您也可以随时重新部署。

- **OpenVPN**
> OpenVPN 要求客户端和服务器应用程序使用其同名的协议建立 VPN 连接。OpenVPN 可以根据您的需求进行调整和定制，但它也需要更多专业技术知识。它支持远程访问和站点到站点配置；如果您计划使用 VPN 作为互联网代理，前者是您所需要的。因为在大多数设备上使用 OpenVPN 需要客户端应用程序，所以最终用户必须保持更新。
> 服务器端您可以选择部署在云端或你自己的 [Linux](https://www.qedev.com/linux/) 服务器上。兼容的发行版包括 CentOS 、Ubuntu 、Debian 和 openSUSE。Windows 、MacOS 、iOS 和 Android 都有客户端应用程序，其他设备也有非官方应用程序。企业可以选择设置一个 OpenVPN 接入服务器，但是对于想要使用社区版的个人来说，这可能有点过分。
> OpenVPN 使用静态密钥加密来配置相对容易，但并不十分安全。相反，我建议使用 easy-rsa 来设置它，这是一个密钥管理包，可以用来设置公钥基础设施（PKI）。这允许您一次连接多个设备，并因此得到 完美前向保密(perfect forward secrecy)和其他好处的保护。OpenVPN 使用 SSL/TLS 进行加密，而且您可以在配置中指定 DNS 服务器。
> OpenVPN 可以穿透防火墙和 NAT 防火墙，这意味着您可以使用它绕过可能会阻止连接的网关和防火墙。它同时支持 TCP 和 UDP 传输。

- **StrongSwan**
> 您可能会遇到一些名称中有 “Swan” 的各种 VPN 工具。FreeS/WAN 、OpenSwan、LibreSwan 和 strongSwan 都是同一个项目的分叉，后者是我个人最喜欢的。在服务器端，strongSwan 可以运行在 [Linux](https://www.qedev.com/linux/) 2.6、3.x 和 4x 内核、Android、FreeBSD、macOS、iOS 和 Windows 上。
> StrongSwan 使用 IKEv2 协议和 IPSec 。与 OpenVPN 相比，IKEv2 连接速度更快，同时提供了很好的速度和安全性。如果您更喜欢不需要在客户端安装额外应用程序的协议，这将非常有用，因为现在生产的大多数新设备都支持 IKEv2，包括 Windows、MacOS、iOS 和 Android。
> StrongSwan 并不特别容易使用，尽管文档不错，但它使用的词汇与大多数其他工具不同，这可能会让人比较困惑。它的模块化设计让它对企业来说很棒，但这也意味着它不是很精简。这当然不像 Algo 或 Streisand 那么简单。
> 访问控制可以基于使用 X.509 属性证书的组成员身份，这是 strongSwan 独有的功能。它支持用于集成到其他环境（如 Windows Active Directory）中的 EAP 身份验证方法。strongSwan 可以穿透NAT 网络防火墙。

- **SoftEther**
> SoftEther 是由日本筑波大学的一名研究生发起的一个项目。SoftEther VPN 服务器和 VPN 网桥可以运行在 Windows、[Linux](https://www.qedev.com/linux/)、OSX、FreeBSD 和 Solaris 上，而客户端应用程序可以运行在 Windows、[Linux](https://www.qedev.com/linux/) 和 MacOS 上。VPN 网桥主要用于需要设置站点到站点 VPN 的企业，因此单个用户只需要服务器和客户端程序来设置远程访问。
> SoftEther 支持 OpenVPN、L2TP、SSTP 和 EtherIP 协议，由于采用“基于 HTTPS 的以太网”伪装，它自己的 SoftEther 协议声称能够免疫深度数据包检测。SoftEther 还做了一些调整，以减少延迟并增加吞吐量。此外，SoftEther 还包括一个克隆功能，允许您轻松地从 OpenVPN 过渡到 SoftEther。
> SoftEther 可以穿透 NAT 防火墙并绕过防火墙。在只允许 ICMP 和 DNS 数据包的受限网络上，您可以利用 SoftEther 的基于 ICMP 或 DNS 的 VPN 方式来穿透防火墙。SoftEther 可与 IPv4 和 IPv6 一起工作。
> SoftEther 比 OpenVPN 和 strongSwan 更容易设置，但比 Streisand 和 Algo 要复杂。

- **WireGuard**
> WireGuard 是这个名单上最新的工具；它太新了，甚至还没有完成。也就是说，它为部署 VPN 提供了一种快速简便的方法。它旨在通过使 IPSec 更简单、更精简来改进它，就像 SSH 一样。
> 与 OpenVPN 一样，WireGuard 既是一种协议，也是一种用于部署使用所述协议的 VPN 的软件工具。一个关键特性是“加密密钥路由”，它将公钥与隧道内允许的 IP 地址列表相关联。
> WireGuard 可用于 Ubuntu、Debian、Fedora、CentOS、MacOS、Windows 和安卓系统。WireGuard 可在 IPv4 和 IPv6 上工作。
> WireGuard 比大多数其他 VPN 协议轻得多，它只在需要发送数据时才发送数据包。
> 开发人员说，WireGuard 还不应该被信任，因为它还没有被完全审计过，但是欢迎你给它一个机会。这可能是下一个热门！

- **自制vpn  VS  商业vpn**
> 制作您自己的 VPN 为您的互联网连接增加了一层隐私和安全，但是如果您是唯一一个使用它的人，那么装备精良的第三方，比如政府机构，将很容易追踪到您的活动。
> 此外，如果您计划使用您的 VPN 来解锁地理锁定的内容，自制的 VPN 可能不是最好的选择。因为您只能从一个 IP 地址连接，所以你的 VPN 服务器很容易被阻止。
> 好的商业 VPN 不存在这些问题。有了像 ExpressVPN 这样的提供商，您可以与数十甚至数百个其他用户共享服务器的 IP 地址，这使得跟踪一个用户的活动几乎变得不可能。您也可以从成百上千的服务器中选择，所以如果其中一台被列入黑名单，您可以切换到另一台。
> 然而，商业 VPN 的权衡是，您必须相信提供商不会窥探您的互联网流量。一定要选择一个有明确的无日志政策的信誉良好的供应商。
> 许多流行的在线安全和VPN供应商都受到了攻击，原因是他们的产品中存在漏洞,以至于让用户面临着严重的威胁。
> 在经历了类似的漏洞之后，思科自适应安全设备解决了SSL的验证问题，但没有讨论是否应该在不受信任的网络上使用它。这些信息的披露让许多组织怀疑他们是否可以继续信任这些行业巨头接触自己的敏感信息，或者他们是否应该完全放弃VPN。
> 尽管在VPN安全网络中暴露的漏洞令人不安，幸运的是，有许多一级的开源VPN解决方案可以满足需求，而且依然有很多的开源替代方案。虽然实现这些解决方案将需要大量的技术知识和高度的合作，但是您可以在晚上睡得更香，因为您知道您的敏感信息正在由最好的安全协议保护着。

