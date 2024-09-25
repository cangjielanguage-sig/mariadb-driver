package cjmd.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import cjmd.connection.*
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

* mysql_native_password -> use: caching_sha2_password ssl:close √
* mysql_native_password -> use: mysql_native_password ssl:close √
* mysql_native_password -> use: sha256_password ssl:close √
* mysql_native_password -> use: caching_sha2_password ssl: open √
* mysql_native_password -> use: mysql_native_password ssl: open √
* mysql_native_password -> use: sha256_password ssl: open √
*/
@Test
public class MySqlTest {


    @TestCase
    public func case1() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "root")
        attr.put(Params.Password, "MySql123!")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

    @TestCase
    public func case2() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "native_user")
        attr.put(Params.Password, "native_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

    @TestCase
    public func case3() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "sha256_user")
        attr.put(Params.Password, "sha256_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

    @TestCase
    public func case4() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "root")
        attr.put(Params.Password, "MySql123!")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        MySqlConnection.createAuthedConnection(attr)
    }

    @TestCase
    public func case5() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "native_user")
        attr.put(Params.Password, "native_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        MySqlConnection.createAuthedConnection(attr)
    }

    @TestCase
    public func case6() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "sha256_user")
        attr.put(Params.Password, "sha256_user")
        attr.put(Params.Host, "localhost")
        attr.put(Params.Port, "3306")
        MySqlConnection.createAuthedConnection(attr)
    }

}