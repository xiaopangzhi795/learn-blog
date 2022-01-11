# 如何安装kibana

## centos
### 进入官网
https://www.elastic.co/cn/

### 下载安装包并解压到对应服务器（注意选择版本要和es和logstash保持一致）
https://www.elastic.co/downloads/past-releases#elasticsearch
选择要下载的服务和对应版本号即可

### 编辑配置文件&启动
```
vim kibana.yml

server.port: 5601
server.host: "127.0.0.1"
elasticsearch.url: "http://127.0.0.1:9200"
kibana.index: ".kibana"


nohup ./bin/kibana &

访问: http://127.0.0.1:5601/

```



### 当logstash安装成功后，进行配置创建索引
在kibana页面选择 ``` create index pattern ```
创建选择下一步即可

![10426470-3b3808f1d9ce4e9a](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/10426470-3b3808f1d9ce4e9a.webp?token=AJTG6CU6V25XN5WFBTDFZQLB3U2BG)

![10426470-7de315c2a2cb5d98](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/10426470-7de315c2a2cb5d98.webp?token=AJTG6CRDYEKJWGPMQKOMZRTB3U2BI)

![10426470-47e2516434321679](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/10426470-47e2516434321679.webp?token=AJTG6CQ2QYR5FEPKKUQPNTTB3U2BK)

![10426470-ff05593636cfc7fd](https://raw.githubusercontent.com/xiaopangzhi795/learn-blog/master/images/10426470-ff05593636cfc7fd.webp?token=AJTG6CVZ6PAUPZW6AMRIXX3B3U2BM)