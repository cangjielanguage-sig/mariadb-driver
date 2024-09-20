package cjmd.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import cjmd.connection.*
import std.collection.*

@Test
public class MySqlTest {


    @TestCase
    public func case1() {
        var attr = HashMap<String, String>()
        attr.put(ConnectionOption.Username, "root")
        attr.put(ConnectionOption.Password, "MySql123!")
        attr.put(ConnectionOption.Host, "localhost")
        attr.put(ConnectionOption.Port, "3306")
        attr.put(ConnectionOption.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

    @TestCase
    public func case2() {
        var attr = HashMap<String, String>()
        attr.put(ConnectionOption.Username, "native_user")
        attr.put(ConnectionOption.Password, "native_user")
        attr.put(ConnectionOption.Host, "localhost")
        attr.put(ConnectionOption.Port, "3306")
        attr.put(ConnectionOption.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

}