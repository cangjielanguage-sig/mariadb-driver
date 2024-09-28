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
