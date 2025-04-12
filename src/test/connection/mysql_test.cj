protected package mysql.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import mysql.connection.*
import std.collection.*
import std.time.*

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

    /*
    * 测试认证插件的兼容情况
    */
    @TestCase
    public func case1(): Unit {
        var attr = HashMap<String, String>()
        attr.add(Params.Username, "caching_user")
        attr.add(Params.Password, "caching_user")
        attr.add(Params.Host, "localhost")
        attr.add(Params.Port, "3306")
        attr.add(Params.SSLMode, "disabled")
        var conn = MySqlConnectionFactory.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case2(): Unit {
        var attr = HashMap<String, String>()
        attr.add(Params.Username, "native_user")
        attr.add(Params.Password, "native_user")
        attr.add(Params.Host, "localhost")
        attr.add(Params.Port, "3306")
        attr.add(Params.SSLMode, "disabled")
        var conn = MySqlConnectionFactory.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case3(): Unit {
        var attr = HashMap<String, String>()
        attr.add(Params.Username, "sha256_user")
        attr.add(Params.Password, "sha256_user")
        attr.add(Params.Host, "localhost")
        attr.add(Params.Port, "3306")
        attr.add(Params.SSLMode, "disabled")
        var conn = MySqlConnectionFactory.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case4(): Unit {
        var attr = HashMap<String, String>()
        attr.add(Params.Username, "caching_user")
        attr.add(Params.Password, "caching_user")
        attr.add(Params.Host, "localhost")
        attr.add(Params.Port, "3306")
        var conn = MySqlConnectionFactory.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case5(): Unit {
        var attr = HashMap<String, String>()
        attr.add(Params.Username, "native_user")
        attr.add(Params.Password, "native_user")
        attr.add(Params.Host, "localhost")
        attr.add(Params.Port, "3306")
        var conn = MySqlConnectionFactory.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case6(): Unit {
        var attr = HashMap<String, String>()
        attr.add(Params.Username, "sha256_user")
        attr.add(Params.Password, "sha256_user")
        attr.add(Params.Host, "localhost")
        attr.add(Params.Port, "3306")
        var conn = MySqlConnectionFactory.createAuthedConnection(attr)
        conn.close()
    }

}