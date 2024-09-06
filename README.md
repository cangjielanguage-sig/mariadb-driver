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
import cjmd.impl.*
import cjmd.connection.*

main(){
    var driver = MySqlDriver.getInstance()
    var property1 = (ConnectionOption.Username, "yesokim")
    var property2 = (ConnectionOption.Password, "yesokim")
    var property3 = (ConnectionOption.Database, "test")
    var dataSource = driver.open("mysql://localhost:3306", [property1,property2,property3])
    var connection =  dataSource.connect()
}
```

#### 3.2.2 插入数据

```
import cjmd.impl.*
import cjmd.connection.*

main(){
    var driver = MySqlDriver.getInstance()
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
import cjmd.impl.*
import cjmd.connection.*

main(){
    var driver = MySqlDriver.getInstance()
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
import cjmd.impl.*
import cjmd.connection.*

main(){
    var driver = MySqlDriver.getInstance()
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
import cjmd.impl.*
import cjmd.connection.*

  main(){
    var driver = MySqlDriver.getInstance()
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
import cjmd.impl.*
import cjmd.connection.*

main(){
    var driver = MySqlDriver.getInstance()
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

## <img alt="" src="./doc/readme-image/readme-icon-contribute.png" style="display: inline-block;" width=3%/>4 参与贡献

本项目由Yesokim实现并维护。技术支持和意见反馈请提Issue。

本项目基于 Apache License 2.0，欢迎给我们提交PR，欢迎参与任何形式的贡献。

本项目commiter：[@Yesokim]()
