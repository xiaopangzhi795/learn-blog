# 如何安装logstash

## centos

### 进入官网
https://www.elastic.co/cn/

### 下载安装包并解压到对应服务器（注意选择版本要和es和kibana保持一致）
https://www.elastic.co/downloads/past-releases#elasticsearch
选择要下载的服务和对应版本号即可



### 编辑配置文件&启动
```
vim logstash-sample.conf

```
### 简单配置模板
``` json
input{
    file{
        # 必选项，配置文件路径，可定义多个，也可模糊匹配;
        path => "/logs/quartz-mapstruct-log-demo/application.log"
        # path => ["name1.json","name2.json", "name3.json"]
        start_position => "beginning"
        type => "quartz_mapstruct_info"
        # 可选项，Logstash多久检查一下path下有新文件，默认15s;
        discover_interval => 15
        # 可选项，logstash多久检查一次被监听文件的变化，默认1s;
        stat_interval => 1
        # 可选项，记录文件以及文件读取信息位置的数据文件;
        #sincedb_path => "/home/ldy/logstash/bs_domain/.sincedb"
		# 可选项，logstash多久写一次sincedb文件，默认15s;
        #sincedb_write_interval => 15
        #mode => "read"
        #file_completed_action => "log"
        #file_completed_log_path => "/var/log/logstash/bs_domain/file.log"
    }
    file{
        path => "/logs/quartz-mapstruct-log-demo/system.log"
        start_position => "beginning"
        type => "quartz_mapstruct_system"
        # 可选项，Logstash多久检查一下path下有新文件，默认15s;
        discover_interval => 15
        # 可选项，logstash多久检查一次被监听文件的变化，默认1s;
        stat_interval => 1
    }
}
# 2.过滤格式化数据阶段
filter {
    mutate {
        # 删除无效的字段
        remove_field => ["_id", "host", "path", "@version", "@timestamp"]
    }
    # 新增timestamp字段，将@timestamp时间增加8小时
    # ruby {code => "event.set('timestamp', event.get('@timestamp').time.localtime + 8*60*60)"}

}
output{
    stdout{
        codec => rubydebug
    }

    if [type] == "quartz_mapstruct_info"{
        elasticsearch{
            hosts => ["172.17.0.4:9200"]
            index => "quartz_mapstruct_info-%{+YYYY.MM.dd}"
        }
    }

    if [type] == "quartz_mapstruct_system"{
        elasticsearch{
            hosts => ["172.17.0.4:9200"]
            index => "quartz_mapstruct_system-%{+YYYY.MM.dd}"
        }
    }
}
```

### 启动logstash

```
//后台启动  不带& 前台启动
./logstash -f ../config/logstash-smple.conf &
```

