package cjmd.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import cjmd.connection.*
import std.collection.*

@Test
public class TidbTest {

    @TestCase
    public func case1() {
        var attr = HashMap<String, String>()
        attr.put(ConnectionOption.Username, "root")
        attr.put(ConnectionOption.Password, "")
        attr.put(ConnectionOption.Host, "47.115.56.208")
        attr.put(ConnectionOption.Port, "4000")
        //attr.put(ConnectionOption.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

}