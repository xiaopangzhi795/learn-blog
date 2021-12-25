# SpringBoot单元测试
Spring boot 自带的依赖包，写单元测试局限性较高，也遇到了种种的问题，将问题整理一下，方便后续翻阅

# 引入依赖
```java
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.junit.vintage</groupId>
            <artifactId>junit-vintage-engine</artifactId>
        </exclusion>
    </exclusions>
    <scope>test</scope>
</dependency>

<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.12</version>
    <scope>test</scope>
</dependency>
```

# 注解说明

``` java
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;

@SpringBootTest
@RunWith(SpringRunner.class)
@ContextConfiguration(classes = {ValidatorServiceTest.class, ExceptionHandlerAspect.class})
@EnableAspectJAutoProxy(proxyTargetClass = true)
@ComponentScan({"com.geek45"})

```

## 说明
- SpringBootTest： spring boot 测试类注解
- RunWith： 容器启动
- ContextConfiguration： 将要注入到容器中的bean对象写进去
- EnableAspectJAutoProxy： 启用切面
- ComponentScan： 扫描bean的路径


# 单测demo
```java
package com.geek45.geekresult;

import com.alibaba.fastjson.JSON;
import com.geek45.geekresult.annotation.aspect.ExceptionHandlerAspect;
import com.geek45.geekresult.exception.BizException;
import com.geek45.geekresult.exception.SystemException;
import com.geek45.geekresult.exception.ValidationException;
import com.geek45.geekresult.util.LoggerUtils;
import com.geek45.geekresult.vo.ResultVO;
import org.apache.commons.lang3.StringUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;

@SpringBootTest
@RunWith(SpringRunner.class)
@ContextConfiguration(classes = {ValidatorServiceTest.class, ExceptionHandlerAspect.class})
@EnableAspectJAutoProxy(proxyTargetClass = true)
@ComponentScan({"com.geek45"})
public class GeekResultApplicationTests {
    private static final Logger logger = LoggerUtils.SYSTEM_LOGGER;

    public GeekResultApplicationTests() {

    }

    @Autowired
    private ValidatorServiceTest validatorServiceTest;

    @Test
    public void checkValidator() {
        logger.info("action check");
        ResultVO result = validatorServiceTest.testValidatorSuccess();
        if (!result.isSuccess()) {
            throw ValidationException.createValidationException(result.getThrowable());
        }
        ResultVO bizException = validatorServiceTest.testError(BizException.class);
        logger.error("bizException exception ..{}", JSON.toJSONString(bizException), bizException.getThrowable());

        ResultVO validatorException = validatorServiceTest.testError(ValidationException.class);
        logger.error("validatorException exception ..{}", JSON.toJSONString(validatorException), validatorException.getThrowable());

        ResultVO systemException = validatorServiceTest.testError(SystemException.class);
        logger.error("systemException exception ..{}", JSON.toJSONString(systemException), systemException.getThrowable());


    }

}

```