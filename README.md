<div align="center">
<h1>Cangjie MySql Driver</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.1.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.54.3-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-0.0%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/state-孵化-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-HOS/Cloud-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/readme-image/readme-icon-introduction.png" style="display: inline-block;" width=3%/> 1 介绍

### 1.1 项目特性

Cangjie MySql Driver是为Cangjie编程语言提供MySql原生驱动程序

### 1.2 项目计划

实现CDBC接口，完成对MySql数据库的基本操作

## <img alt="" src="./doc/readme-image/readme-icon-framework.png" style="display: inline-block;" width=3%/> 2 架构

### 2.1 项目结构

```shell
.
├── doc
    └── readme-image
└── src
    ├── connection
    ├── impl
    ├── packet
    └── result
├── CHANGELOG
├── cjpm.lock
├── cjpm.toml
├── LICENSE
├── README.md
```

### 2.2 接口说明

## <img alt="" src="./doc/readme-image/readme-icon-compile.png" style="display: inline-block;" width=3%/> 3 使用说明

> 仓颉提供的摘要算法和加密算法依赖 OpenSSL 3 的 crypto 动态库文件,因此使用本驱动时需要确保当前环境的OpenSSL版本为3.x

### 3.1 编译构建（Win/Linux/Mac）

```
[dependencies]
  cjmd = {git = "https://gitcode.com/weixin_64400442/cjmd.git", branch="master", version = "1.0.0"}
```

### 3.2 功能示例

```sql
CREATE TABLE `test` (
`id` int NOT NULL AUTO_INCREMENT,
`varchar_col` varchar(255) DEFAULT NULL,
`char_col` char(10) DEFAULT NULL,
`tinyint_col` tinyint DEFAULT NULL,
`smallint_col` smallint DEFAULT NULL,
`mediumint_col` mediumint DEFAULT NULL,
`int_col` int DEFAULT NULL,
`bigint_col` bigint DEFAULT NULL,
`float_col` float(8,2) DEFAULT NULL,
`double_col` double(10,4) DEFAULT NULL,
`decimal_col` decimal(10,5) DEFAULT NULL,
`date_col` date DEFAULT NULL,
`datetime_col` datetime DEFAULT NULL,
`timestamp_col` timestamp NULL DEFAULT NULL,
`time_col` time DEFAULT NULL,
`year_col` year DEFAULT NULL,
PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

#### 3.2.1 获取连接

```
import cjmd.*
import cjmd.connection.*

main(){
    var driver = DriverManager.getDriver("mysql").getOrThrow()
    var property1 = (ConnectionOption.Username, "yesokim")
    var property2 = (ConnectionOption.Password, "yesokim")
    var property3 = (ConnectionOption.Database, "test")
    var dataSource = driver.open("mysql://localhost:3306", [property1,property2,property3])
    var connection =  dataSource.connect()
}
```

#### 3.2.2 插入数据

```
import cjmd.*
import cjmd.connection.*
import std.database.sql.*

main(){
    var driver = DriverManager.getDriver("mysql").getOrThrow()
    var property1 = (ConnectionOption.Username, "yesokim")
    var property2 = (ConnectionOption.Password, "yesokim")
    var property3 = (ConnectionOption.Database, "test")
    var dataSource = driver.open("mysql://localhost:3306", [property1,property2,property3])
    var connection =  dataSource.connect()
    var prepare = connection.prepareStatement("insert into test (varchar_col, char_col, tinyint_col, smallint_col, mediumint_col,    int_col, bigint_col, float_col, double_col, decimal_col, date_col, datetime_col, timestamp_col, time_col, year_col) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
    var param1 = SqlVarchar("varchar")
    var param2 = SqlChar("char")
    var param3 = SqlByte(8)
    var param4 = SqlSmallInt(16)
    var param5 = SqlInteger(24)
    var param6 = SqlInteger(32)
    var param7 = SqlBigInt(64)
    var param8 = SqlReal(30.45780)
    var param9 = SqlDouble(30.234)
    var param10 = SqlDouble(30.823567543567)
    var param11 = SqlDate(DateTime.now())
    var param12 = SqlTimestamp(DateTime.now())
    var param13 = SqlTimestamp(DateTime.now())
    var param14 = SqlTime(DateTime.now())
    var param15 = SqlSmallInt(2024)
    var result = prepare.update([param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11,param12,param13,param14,param15])
    println("effect rows: ${result.rowCount}")
    println("last insert id: ${result.lastInsertId}")
}
```

#### 3.2.3 删除数据

```
import cjmd.*
import cjmd.connection.*
import std.database.sql.*

main(){
    var driver = DriverManager.getDriver("mysql").getOrThrow()
    var property1 = (ConnectionOption.Username, "yesokim")
    var property2 = (ConnectionOption.Password, "yesokim")
    var property3 = (ConnectionOption.Database, "test")
    var connection =  dataSource.connect()
    var prepare = connection.prepareStatement("delete from test where id = ?")
    var param = SqlInteger(15)
    var result = prepare.update([param])
 
    println("effect rows: ${result.rowCount}")
    println("last insert id: ${result.lastInsertId}")
}
```

### 3.2.4 更新数据

```
import cjmd.*
import cjmd.connection.*
import std.database.sql.*

main(){
    var driver = DriverManager.getDriver("mysql").getOrThrow()
    var property1 = (ConnectionOption.Username, "yesokim")
    var property2 = (ConnectionOption.Password, "yesokim")
    var property3 = (ConnectionOption.Database, "test")
    var dataSource = driver.open("mysql://localhost:3306", [property1,property2,property3])
    var connection =  dataSource.connect()
    var prepare = connection.prepareStatement("update test set varchar_col = ? where varchar_col = ?")
    var param1 = SqlChar("yesokim")
    var param2 = SqlChar("varchar")
    var result = prepare.update([param1,param2])

    println("effect rows: ${result.rowCount}")  
    println("last insert id: ${result.lastInsertId}")
}
```

#### 3.2.5 查询数据

```
import cjmd.*
import cjmd.connection.*
import std.database.sql.*

main(){
    var driver = DriverManager.getDriver("mysql").getOrThrow()
    var property1 = (ConnectionOption.Username, "yesokim")
    var property2 = (ConnectionOption.Password, "yesokim")
    var property3 = (ConnectionOption.Database, "test")
    var dataSource = driver.open("mysql://localhost:3306", [property1,property2,property3])
    var connection =  dataSource.connect()
    var prepare = connection.prepareStatement("select * from test where id = ?")

    var param = SqlInteger(10)

    var id = SqlInteger(-1)
    var col1 = SqlNullableVarchar(None)
    var col2 = SqlNullableChar(None)
    var col3 = SqlNullableByte(None)
    var col4 = SqlNullableSmallInt(None)
    var col5 = SqlNullableInteger(None)

    var row: Array<SqlDbType> = [id,col1,col2,col3,col4,col5]

    while (result.next(row)) {
            println("${id.value} ${col1.value} ${col2.value} ${col3.value} ${col4.value} ${col5.value}")
    }

}
```

#### 3.2.6 获取事务对象

```
import cjmd.*
import cjmd.connection.*
import std.database.sql.*

main(){
    var driver = DriverManager.getDriver("mysql").getOrThrow()
    var property1 = (ConnectionOption.Username, "yesokim")
    var property2 = (ConnectionOption.Password, "yesokim")
    var property3 = (ConnectionOption.Database, "test")
    var dataSource = driver.open("mysql://localhost:3306", [property1,property2,property3])
    var connection =  dataSource.connect()
    var transaction = connection.createTransaction()
    transaction.begin()
    transaction.commit()
}
```

## 3.3 连接参数

| 选项名                  | 功能                                                         | 可选值                                                     | 默认值    | Require                           |
| ----------------------- | ------------------------------------------------------------ | ---------------------------------------------------------- | --------- | --------------------------------- |
| username                | 数据库用户名                                                 |                                                            |           | Yes                               |
| password                | 数据库密码                                                   |                                                            |           | Yes                               |
| host                    | 主机地址                                                     |                                                            |           | Yes                               |
| port                    | 服务端口                                                     |                                                            | 3306      | No                                |
| database                | 数据库                                                       |                                                            |           | No                                |
| connection_timeout      | connect 操作的超时时间，单位 ms。                            |                                                            |           | No                                |
| query_timeout           | query 操作的超时时间，单位 ms。                              |                                                            |           | No                                |
| update_timeout          | update 操作的超时时间，单位 ms。                             |                                                            |           | No                                |
| encoding                | 数据库字符集编码类型。当前仅支持UTF-8                        |                                                            | utf-8     | No                                |
| ssl.mode                | 传输层加密模式。                                             | disabled,preferred(default),required,verify_ca,verify_full | preferred | No                                |
| ssl.ca                  | 证书颁发机构（ CA ）证书文件的路径名                         |                                                            |           | No                                |
| ssl.cert                | 客户端 SSL 公钥证书文件的路径名。                            |                                                            |           | No                                |
| ssl.key                 | 客户端 SSL 私钥文件的路径名。                                |                                                            |           | 使用了ssl.cert必须指定ssl.key参数 |
| ssl.key.password        | 客户端 SSL 私钥文件的密码。                                  |                                                            |           | No                                |
| ssl.sni                 | 客户端通过该标识在握手过程开始时试图连接到哪个主机名。       |                                                            |           | No                                |
| tls1.2.ciphersuites     | 此选项指定客户端允许使用 TLSv1.2 及以下的加密连接使用哪些密码套件。 |                                                            |           | No                                |
| tls1.3.ciphersuites     | 此选项指定客户端允许使用 TLSv1.3 的加密连接使用哪些密码套件。 |                                                            |           | No                                |
| tls.version             | 支持的 TLS 版本号，值为逗号分隔的字符串，比如 "TLSv1.2,TLSv1.3"。 |                                                            |           | No                                |
| pool.connection_timeout | 从池中获取连接的超时时间。单位 s                             |                                                            | 30        | No                                |
| pool.idle_timeout       | 允许连接在池中闲置的最长时间，超过这个时间的空闲连接可能会被回收。单位 m |                                                            | 10        | No                                |
| pool.keepalive_time     | 检查空闲连接健康状况的间隔时间，防止它被数据库或网络基础设施超时。单位 m |                                                            | 1         | No                                |
| pool.max_idle_size      | 最大空闲连接数量，超过这个数量的空闲连接会被关闭，负数或0表示无限制。 |                                                            | 0         | No                                |
| pool.max_life_time      | 自连接创建以来的持续时间，在该持续时间之后，连接将自动关闭。单位 m |                                                            | 30        | No                                |
| pool.max_size           | 连接池最大连接数量，负数或0表示无限制。                      |                                                            | 10        | No                                |
| prepare.mode            | 预编译模式                                                   | auto: 自动选择, server: 服务端预编译, client: 客户端预编译 | auto      | No                                |

## <img alt="" src="./doc/readme-image/readme-icon-contribute.png" style="display: inline-block;" width=3%/>4 参与贡献

本项目由Yesokim实现并维护。技术支持和意见反馈请提Issue。

本项目基于 Apache License 2.0，欢迎给我们提交PR，欢迎参与任何形式的贡献。

本项目commiter：[@Yesokim](https://gitcode.com/weixin_64400442)
