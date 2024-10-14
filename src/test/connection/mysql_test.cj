protected package mysqlclient4cj.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import mysqlclient4cj.connection.*
import std.collection.*

/*
* 测试认证插件的兼容情况
* default: caching_sha2_password -> use: caching_sha2_password ssl:close √
* default: caching_sha2_password -> use: mysql_native_password ssl:close √
* default: caching_sha2_password -> use: sha256_password ssl:close √
* default: caching_sha2_password -> use: caching_sha2_password ssl: open √
* default: caching_sha2_password -> use: mysql_native_password ssl: open √
* default: caching_sha2_password -> use: sha256_password ssl: open √

* default: sha256_password -> use: caching_sha2_password ssl:close √
* default: sha256_password -> use: mysql_native_password ssl:close √
* default: sha256_password -> use: sha256_password ssl:close √
* default: sha256_password -> use: caching_sha2_password ssl: open √
* default: sha256_password -> use: mysql_native_password ssl: open √
* default: sha256_password -> use: sha256_password ssl: open √

* default: mysql_native_password -> use: caching_sha2_password ssl:close √
* default: mysql_native_password -> use: mysql_native_password ssl:close √
* default: mysql_native_password -> use: sha256_password ssl:close √
* default: mysql_native_password -> use: caching_sha2_password ssl: open √
* default: mysql_native_password -> use: mysql_native_password ssl: open √
* default: mysql_native_password -> use: sha256_password ssl: open √
*/
@Test
public class MySqlTest {


    @TestCase
    public func case1(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "root")
        attr.put(Params.Password, "MySql123!")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case2(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "native_user")
        attr.put(Params.Password, "native_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case3(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "sha256_user")
        attr.put(Params.Password, "sha256_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case4(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "root")
        attr.put(Params.Password, "MySql123!")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case5(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "native_user")
        attr.put(Params.Password, "native_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case6(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "sha256_user")
        attr.put(Params.Password, "sha256_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

}