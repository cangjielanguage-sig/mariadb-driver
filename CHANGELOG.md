# [V0.1.0]

## Feature

- 实现CDBC接口
- 支持caching_sha2_password和sha256_password认证插件
- 支持SSL/TLS安全连接

# [v0.2.0]

## Feature

- 完成了对服务端Prepare的支持

# [v0.2.1]

## Feature

- 完善了对json、set、enum类型的支持

# [v0.2.2]

## Feature

- 修复了使用服务端prepare插入Decimal类型时出现错误的bug

# [v0.2.3]

## Feature

- 向DriverManager注册了驱动,优化了导包流程

# [v0.3.0]

## Feature

- 修复了getArray()数据不准确的bug
- 添加了经典的JDBC接口支持

# [v0.3.1]

## Feature

- 添加了对mysql_native_password认证插件的支持
- 支持国产数据库TIDB
- 完善了jdbc接口的实现

# [v0.3.2]

## Feature

- 支持国产数据库OceanBase

## Bugfix

- 修复了某些认证插件在进行ssl连接后认证失败的bug

# [v0.3.3]

## Bugfix

- 修复了jdbc接口插入Null值失败的bug

# [v0.3.4]

## Feature

- 添加了的BigInt的支持

# [v0.3.5]

## Feature

- 完善了jdbc接口中的Date、Time类型

# [v0.4.0]

项目更名为**mysqlclient4cj**

# [v0.5.0]

## Feature

- Cangjie版本升级为0.56.4

# [v0.5.1]

## Feature

- 添加对fetch功能的支持,可以通过fetchSize参数设置每次从服务器拉取的结果集数量, 避免查询结果集过大导致程序内存溢出

# [v0.6.0]
2024-11-7

## Message

- 优化了程序运行流程，减少了在解析数据包时不必要的内存拷贝

- 优化了代码整体的质量

# [v0.6.1]
2024-11-17

## Feature

- 新增了操作xa协议的api

# [v0.7.0]
2024-11-17

## Rename

- 更名为项目更名为mysql-driver
- 移除jdbc接口实现