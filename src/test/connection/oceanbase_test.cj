package cjmd.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import cjmd.connection.*
import std.collection.*

@Test
public class OceanBaseTest {

    @TestCase
    public func case1() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "yesokim")
        attr.put(Params.Password, "^ynAW@7W5Fdxi6f")
        attr.put(Params.Host, "obmtm94oeja8d1h0-mi.cn-hangzhou.oceanbase.aliyuncs.com")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

    @TestCase
    public func case2() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "yesokim")
        attr.put(Params.Password, "^ynAW@7W5Fdxi6f")
        attr.put(Params.Host, "obmtm94oeja8d1h0-mi.cn-hangzhou.oceanbase.aliyuncs.com")
        attr.put(Params.Port, "3306")
        MySqlConnection.createAuthedConnection(attr)
    }

}