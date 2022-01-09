# es安装教程

## centos 安装教程

### 进入官网
https://www.elastic.co/cn/

### 下载安装包并解压到对应服务器
https://www.elastic.co/downloads/past-releases#elasticsearch
选择要下载的服务和对应版本号即可

### 配置es
- 进入es的config目录
- 修改配置文件

``` 
vim elasticsearch.yml 
```

- 修改配置内容

```
cluster.name: elk
node.name: elasticsearch
network.host: 127.0.0.1
http.port: 9200
http.cors.enabled: true
http.cors.allow-origin: "*"
path.data: /opt/elk/elasticsearch-6.3.0/data
path.logs: /opt/elk/elasticsearch-6.3.0/logs

```

### 启动es
``` shell
//前台启动
./elasticsearch  

// 后台启动
./elasticsearch &  
或者  
./elasticsearch -d 
```

### 测试启动结果
- 浏览器访问 http://127.0.0.1:9200
- curl获取结果

```
curl http://127.0.0.1:9200
```

- 能获取到以下结果说明启动成功

``` json
{
  "name" : "elasticsearch",
  "cluster_name" : "elk",
  "cluster_uuid" : "denNwaHWRriGdxn1-nBg4g",
  "version" : {
    "number" : "7.10.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "51e9d6f22758d0374a0f3f5c6e8f3a7997850f96",
    "build_date" : "2020-11-09T21:30:33.964949Z",
    "build_snapshot" : false,
    "lucene_version" : "8.7.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```