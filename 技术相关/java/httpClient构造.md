<a name="CmktL"></a>
# 参数
<a name="U0Qp6"></a>
## 配置解析
<a name="gpfkF"></a>
### 连接管理器
org.apache.http.impl.conn.PoolingHttpClientConnectionManager---new PoolingHttpClientConnectionManager();

- maxTotal：最大连接数
- defaultMaxPerRoute：每个路由的最大连接数
- maxPerRoute：设置到某个路由的最大连接数，会覆盖defaultMaxPerRoute
- defaulSocketConfig：socket默认配置
- socketConfig：某个host的socket配置
- defaultConnectionConfig：http connection默认配置，一般不会更改该配置
- connectionConfig：针对某个host的http connection配置，一般不会更改该配置
<a name="Pjhxd"></a>
#### socket配置，默认配置和某个host的配置
org.apache.http.config.SocketConfig---SocketConfig._custom_();

- tcpNoDelay：是否立即发送数据，设置为true会关闭Socket缓冲，默认为false。
- soReuseAddress：是否可以在一个进程关闭Socket后，即使它还没有释放端口，其他进程还可以立即重用端口
- soTimeout：接收数据的等待超市时间，单位ms
- soLinger：关闭Socket时，要么发送完所有数据，要么等待60s（配置的值）后，就关闭连接。此时socket.close()时阻塞的。
- soKeepAlive：开启监视TCP链接是否有效
- backlogSize：backlog设置容量限制功能，避免太多的客户端socket占用太多的服务器资源
- rcvBufSize：接受缓冲区大小
- sndBufSize：发送缓冲区大小
<a name="FuPBq"></a>
#### HTTP connection相关配置，一般不会更改该配置
org.apache.http.config.ConnectionConfig---ConnectionConfig.custom()

- bufferSize：缓存区大小
- charset：编码
- framentSizeHint：碎片大小
- malformedInputAction
- unmappableInputAction
- 消息约束：messageConstraints
<a name="iAN3s"></a>
##### 消息约束，一般不会更改该配置
org.apache.http.config.MessageConstraints---MessageConstraints.custom()

- maxHeaderCount
- maxLineLength
<a name="yKZYA"></a>
### request请求相关配置
org.apache.http.client.config.RequestConfig---RequestConfig.custom()

- connectionTimeout：连接超时时间
- socketTimeout：读取超时时间（等待数据超时时间）
- connectionRequestTimeout：从池中获取连接超时时间
- staleConnectionCheckEnabled：检查是否为陈旧的连接，默认为true，类似testOnBorrow
- authenticationEnable：是否自动处理身份验证
- circularRedirectsAllowed：确定循环重定向（重定向到相同位置）是否应该重定向
- maxRedirects：重定向的最大数目，防止无限循环
- RelativeRedirectsAllowed：是否应拒绝重定向
- cookiSpec：确定用于HTTP状态管理的cookie规范的名称
- localAddress：具有多个网络接口的计算机上，此参数用于选择启用的网络接口连接产生
- proxy：代理
- proxyPreferredAuthSchemes：使用代理主机进行身份验证时，确定支持的身份验证方案的优先顺序
- targetPreferredAuthSchemes：使用代理主机进行身份验证时，确定支持的身份验证方案的首选项顺序
<a name="zzEuF"></a>
### 重试处理，默认重试三次
org.apache.http.client.HttpRequestRetryHandler--new DefaultHttpRequestRetryHandler(0, false);

- retryCount：重试次数
- requestSentRetryEnabled：是否禁用重试
<a name="sLEMV"></a>
### 自定义重试策略
org.apache.http.client.HttpRequestRetryHandler--new HttpRequestRetryHandler(){}

- retryRequest：返回true就重试，false就不重试，可根据实际业务来写逻辑是否重试。入参是：IOException，executionCount，HttpContext。
   - IOException：异常详情
   - executionCount：已经重试过的次数
   - HttpContext：请求内容
<a name="OWxPN"></a>
### 创建httpClient
org.apache.http.impl.client.CloseableHttpClient---HttpClients.custom()

- connectionManager：连接管理器
- proxy：设置代理
   - host：代理地址
   - port：代理端口
- defaultRequestConfig：默认请求配置
- retryHandler：重试策略
- maxConnTotal：全局最大连接数
- MaxConnPerRoute：单个Route最大连接数
- evictIdleConnections：设置最长空闲时间以及时间单位。会同时设置evictIdleConnections=ture，表示开启独立线程清理空闲连接。
- expiredConnections：开启独立线程清理过期连接
- useSystemProperties：是否读取系统属性，调用该方法则可以获取
- disableAuthCaching：是否禁用缓存
- disableRedirectHandling：是否禁用重定向
- disableContentConpression：是否禁用内容压缩
- disableAutomaticRetries：是否禁用自动重试
- disableCookieManagement：是否禁用cookie管理
- disableConnectionState：是否禁用连接状态

<a name="zG1fO"></a>
### SSL
javax.net.ssl.SSLContext

- loadKeyMaterial：家在客户端证书用的
- loadTrustMaterial：家在服务器相关信息用的。TrustAllStrategy，就是不对服务器端的证书进行校验

如果我们只需要忽略掉对服务器端证书的验证，而不需要发送客户端证书信息,在构建SSLContext的时候，只需要 loadTrustMaterial() 不需要 loadKeyMaterial()

<a name="lBbWB"></a>
## 配置说明
<a name="RmBgj"></a>
### 什么是路由？

<a name="qHAXf"></a>
### 开启SSL

<a name="NlGoU"></a>
### 开启代理

<a name="SK9kQ"></a>
### SSL证书校验

<a name="fIt1y"></a>
### 重试策略

<a name="U0kQx"></a>
### 连接管理器

<a name="T259C"></a>
## 常用配置
```
				logger.info("enableHttpClient|class={}", CloseableHttpClient.class.getName());

        //socket配置
        SocketConfig socketConfig = SocketConfig.custom()
                .setTcpNoDelay(Boolean.TRUE)
                .setSoReuseAddress(Boolean.TRUE)
                .setSoLinger(60)
                .setSoKeepAlive(Boolean.TRUE)
                .build();

        //忽略掉对服务器端证书的校验
        SSLContext sslcontext = SSLContexts.custom()
                .loadTrustMaterial(new TrustAllStrategy())
                .build();

        SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(sslcontext,
                NoopHostnameVerifier.INSTANCE);
        Registry<ConnectionSocketFactory> registry = RegistryBuilder.<ConnectionSocketFactory> create()
                .register("http", new PlainConnectionSocketFactory())
                .register("https", sslConnectionSocketFactory)
                .build();

        //连接管理器
        PoolingHttpClientConnectionManager connectionManager = new PoolingHttpClientConnectionManager(registry);
        connectionManager.setMaxTotal(256);
        connectionManager.setDefaultMaxPerRoute(128);
        connectionManager.closeIdleConnections(600, TimeUnit.SECONDS);
        connectionManager.setDefaultSocketConfig(socketConfig);

        //请求配置
        RequestConfig.Builder requestBuilder = RequestConfig.custom()
                .setConnectTimeout(1000 * 3)
                .setSocketTimeout(1000 * 10)
                .setConnectionRequestTimeout(1000 * 10)
                .setMaxRedirects(3)
                .setAuthenticationEnabled(Boolean.TRUE);

        if (false) {
            HttpHost host = new HttpHost("http://192.168.1.1", 7890);
            requestBuilder.setProxy(host);
        }

        //重试
        HttpRequestRetryHandler retryHandler = new DefaultHttpRequestRetryHandler(3, true);

        HttpClientBuilder builder = HttpClients.custom()
                .disableAuthCaching()
                .disableAutomaticRetries()
                .evictExpiredConnections()
                .setConnectionManager(connectionManager)
                .setRetryHandler(retryHandler)
                .setDefaultRequestConfig(requestBuilder.build());

        if (StringUtils.isNotBlank(httpClientProperties.getUserAgent())) {
            builder.setUserAgent(httpClientProperties.getUserAgent());
        }

        return builder.build();
```

<a name="AKLcl"></a>
## 自定义配置类
```
/**
 * Alibab-inc.com Inc.
 * Copyright (c) 2004-2022 All Rights Reserved.
 */
package com.alibaba.smartwaring.commons.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * @Description:
 * @author: qian
 * @Date: created of 2022/3/3 6:00 PM for HttpClientProperties.java
 */
@ConfigurationProperties(prefix = "heartbeat.config.httpclient")
public class HttpClientProperties {

    public static final String HTTP = "http";
    public static final String HTTPS = "https";

    /**
     * 是否启用
     */
    private Boolean enable = Boolean.FALSE;

    /**
     * 立即发送数据，是否关闭缓冲区
     */
    private Boolean tcpNoDelay = Boolean.TRUE;

    /**
     * socket关闭时，还没有释放端口时，其他进程是否可以立即重用端口
     */
    private Boolean soReuseAddress = Boolean.TRUE;

    /**
     * 关闭socket时，等待数据发送时间为多久。单位秒
     */
    private Integer socketLinger = 60;

    /**
     * 是否监听TCP链接是否有效
     */
    private Boolean socketKeepAlive = Boolean.TRUE;

    /**
     * 最大连接数
     */
    private Integer maxTotal = 256;

    /**
     * 最大路由数量
     */
    private Integer maxPerRoute = 128;

    /**
     * 最长空闲时间
     */
    private Long connectionIdleTimeoutSec = 600L;

    /**
     * 连接超时时间
     */
    private Integer connectTimeoutMillis = 1000 * 3;

    /**
     * 读取超时时间
     */
    private Integer soTimeoutMillis = 1000 * 10;

    /**
     * 从池子中获取连接超时时间
     */
    private Integer connectionRequestTimeoutMillis = 1000 * 10;

    /**
     * 重定向最大次数
     */
    private Integer maxRedirects = 3;

    /**
     * 是否自动处理身份验证
     */
    private Boolean authenticationEnabled = Boolean.TRUE;

    /**
     * 默认重试次数
     */
    private Integer retryCount = 3;

    /**
     * 请求是否自动重试
     */
    private Boolean requestSendRetryEnabled = Boolean.TRUE;

    /**
     * 代理连接，如：http://192.168.1.1:7890，需要类型，地址，端口
     */
    private String proxyAddress;

    /**
     * 客户端标识
     */
    private String userAgent;

    /**
     * 最大返回结果数量
     */
    private Long maxResponseBytes = 1024L * 1024 * 10;

    public Boolean getEnable() {
        return enable;
    }

    public void setEnable(Boolean enable) {
        this.enable = enable;
    }

    public Integer getMaxTotal() {
        return maxTotal;
    }

    public void setMaxTotal(Integer maxTotal) {
        this.maxTotal = maxTotal;
    }

    public Integer getMaxPerRoute() {
        return maxPerRoute;
    }

    public void setMaxPerRoute(Integer maxPerRoute) {
        this.maxPerRoute = maxPerRoute;
    }

    public Long getConnectionIdleTimeoutSec() {
        return connectionIdleTimeoutSec;
    }

    public void setConnectionIdleTimeoutSec(Long connectionIdleTimeoutSec) {
        this.connectionIdleTimeoutSec = connectionIdleTimeoutSec;
    }

    public Integer getConnectTimeoutMillis() {
        return connectTimeoutMillis;
    }

    public void setConnectTimeoutMillis(Integer connectTimeoutMillis) {
        this.connectTimeoutMillis = connectTimeoutMillis;
    }

    public Integer getSoTimeoutMillis() {
        return soTimeoutMillis;
    }

    public void setSoTimeoutMillis(Integer soTimeoutMillis) {
        this.soTimeoutMillis = soTimeoutMillis;
    }

    public Integer getConnectionRequestTimeoutMillis() {
        return connectionRequestTimeoutMillis;
    }

    public void setConnectionRequestTimeoutMillis(Integer connectionRequestTimeoutMillis) {
        this.connectionRequestTimeoutMillis = connectionRequestTimeoutMillis;
    }

    public Integer getMaxRedirects() {
        return maxRedirects;
    }

    public void setMaxRedirects(Integer maxRedirects) {
        this.maxRedirects = maxRedirects;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    public Long getMaxResponseBytes() {
        return maxResponseBytes;
    }

    public void setMaxResponseBytes(Long maxResponseBytes) {
        this.maxResponseBytes = maxResponseBytes;
    }

    public Boolean getTcpNoDelay() {
        return tcpNoDelay;
    }

    public void setTcpNoDelay(Boolean tcpNoDelay) {
        this.tcpNoDelay = tcpNoDelay;
    }

    public Boolean getSoReuseAddress() {
        return soReuseAddress;
    }

    public void setSoReuseAddress(Boolean soReuseAddress) {
        this.soReuseAddress = soReuseAddress;
    }

    public Integer getSocketLinger() {
        return socketLinger;
    }

    public void setSocketLinger(Integer socketLinger) {
        this.socketLinger = socketLinger;
    }

    public Boolean getSocketKeepAlive() {
        return socketKeepAlive;
    }

    public void setSocketKeepAlive(Boolean socketKeepAlive) {
        this.socketKeepAlive = socketKeepAlive;
    }

    public Boolean getAuthenticationEnabled() {
        return authenticationEnabled;
    }

    public void setAuthenticationEnabled(Boolean authenticationEnabled) {
        this.authenticationEnabled = authenticationEnabled;
    }

    public Integer getRetryCount() {
        return retryCount;
    }

    public void setRetryCount(Integer retryCount) {
        this.retryCount = retryCount;
    }

    public Boolean getRequestSendRetryEnabled() {
        return requestSendRetryEnabled;
    }

    public void setRequestSendRetryEnabled(Boolean requestSendRetryEnabled) {
        this.requestSendRetryEnabled = requestSendRetryEnabled;
    }

    public String getProxyAddress() {
        return proxyAddress;
    }

    public void setProxyAddress(String proxyAddress) {
        this.proxyAddress = proxyAddress;
    }
}

```


<a name="HAFaM"></a>
## httpclient配置类
```
/**
 * Alibab-inc.com Inc.
 * Copyright (c) 2004-2022 All Rights Reserved.
 */
package com.alibaba.smartwaring.commons.config;

import com.alibaba.smartwaring.commons.client.RestHttpClient;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpHost;
import org.apache.http.client.HttpClient;
import org.apache.http.client.HttpRequestRetryHandler;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.config.SocketConfig;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.TrustAllStrategy;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.DefaultHttpRequestRetryHandler;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.ssl.SSLContexts;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import javax.annotation.Resource;
import javax.net.ssl.SSLContext;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.util.concurrent.TimeUnit;

/**
 * @Description:
 * @author: qian
 * @Date: created of 2022/3/3 6:13 PM for HttpClientConfiguration.java
 */
@Configuration
@ConditionalOnProperty(prefix = "heartbeat.config.httpclient", name = "enable", havingValue = "true")
public class HttpClientConfiguration {
    private static final Logger logger = LoggerFactory.getLogger(HttpClientConfiguration.class);

    @Resource
    private HttpClientProperties httpClientProperties;


    @Bean
    public CloseableHttpClient httpClient() throws NoSuchAlgorithmException, KeyStoreException, KeyManagementException {
        logger.info("enableHttpClient|class={}", CloseableHttpClient.class.getName());

        //socket配置
        SocketConfig socketConfig = SocketConfig.custom()
                .setTcpNoDelay(httpClientProperties.getTcpNoDelay())
                .setSoReuseAddress(httpClientProperties.getSoReuseAddress())
                .setSoLinger(httpClientProperties.getSocketLinger())
                .setSoKeepAlive(httpClientProperties.getSocketKeepAlive())
                .build();

        //忽略掉对服务器端证书的校验
        SSLContext sslcontext = SSLContexts.custom()
                .loadTrustMaterial(new TrustAllStrategy())
                .build();

        SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(sslcontext,
                NoopHostnameVerifier.INSTANCE);
        Registry<ConnectionSocketFactory> registry = RegistryBuilder.<ConnectionSocketFactory> create()
                .register(HttpClientProperties.HTTP, new PlainConnectionSocketFactory())
                .register(HttpClientProperties.HTTPS, sslConnectionSocketFactory)
                .build();

        //连接管理器
        PoolingHttpClientConnectionManager connectionManager = new PoolingHttpClientConnectionManager(registry);
        connectionManager.setMaxTotal(httpClientProperties.getMaxTotal());
        connectionManager.setDefaultMaxPerRoute(httpClientProperties.getMaxPerRoute());
        connectionManager.closeIdleConnections(httpClientProperties.getConnectionIdleTimeoutSec(), TimeUnit.SECONDS);
        connectionManager.setDefaultSocketConfig(socketConfig);

        //请求配置
        RequestConfig.Builder requestBuilder = RequestConfig.custom()
                .setConnectTimeout(httpClientProperties.getConnectTimeoutMillis())
                .setSocketTimeout(httpClientProperties.getSoTimeoutMillis())
                .setConnectionRequestTimeout(httpClientProperties.getConnectionRequestTimeoutMillis())
                .setMaxRedirects(httpClientProperties.getMaxRedirects())
                .setAuthenticationEnabled(httpClientProperties.getAuthenticationEnabled());

        if (StringUtils.isNotBlank(httpClientProperties.getProxyAddress())) {
            HttpHost host = HttpHost.create(httpClientProperties.getProxyAddress());
            requestBuilder.setProxy(host);
        }

        //重试
        HttpRequestRetryHandler retryHandler = new DefaultHttpRequestRetryHandler(httpClientProperties.getRetryCount(), httpClientProperties.getRequestSendRetryEnabled());

        HttpClientBuilder builder = HttpClients.custom()
                .disableAuthCaching()
                .disableAutomaticRetries()
                .evictExpiredConnections()
                .setConnectionManager(connectionManager)
                .setRetryHandler(retryHandler)
                .setDefaultRequestConfig(requestBuilder.build());

        if (StringUtils.isNotBlank(httpClientProperties.getUserAgent())) {
            builder.setUserAgent(httpClientProperties.getUserAgent());
        }

        return builder.build();
    }

    @Bean
    public RestTemplate restTemplate(@Autowired HttpClient httpClient) {
        logger.info("enableRestTemplate|class={}", RestTemplate.class.getName());
        HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory(httpClient);
        return new RestTemplate(factory);
    }

    @Bean
    public RestHttpClient restHttpClient(@Autowired HttpClient httpClient) {
        logger.info("enableRestHttpClientService|class={}", RestHttpClient.class.getName());
        return new RestHttpClient(httpClientProperties, httpClient);
    }
}

```














