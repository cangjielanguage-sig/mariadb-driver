protected package mysqlclient4cj.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import mysqlclient4cj.connection.*
import std.collection.*

@Test
public class OceanBaseTest {

    @TestCase
    public func case1(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "yesokim")
        attr.put(Params.Password, "^ynAW@7W5Fdxi6f")
        attr.put(Params.Host, "obmtm94oeja8d1h0-mi.cn-hangzhou.oceanbase.aliyuncs.com")
        attr.put(Params.Port, "3306")
        attr.put(Params.SSLMode, "disabled")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

    @TestCase
    public func case2(): Unit {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "yesokim")
        attr.put(Params.Password, "^ynAW@7W5Fdxi6f")
        attr.put(Params.Host, "obmtm94oeja8d1h0-mi.cn-hangzhou.oceanbase.aliyuncs.com")
        attr.put(Params.Port, "3306")
        var conn = MySqlConnection.createAuthedConnection(attr)
        conn.close()
    }

}