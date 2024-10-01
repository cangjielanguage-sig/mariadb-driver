protected package cjmd.test.connection

import std.unittest.*
import std.unittest.testmacro.*
import cjmd.connection.*
import std.collection.*

@Test
public class TidbTest {
    
    @TestCase
    public func case1() {
        var attr = HashMap<String, String>()
        attr.put(Params.Username, "3VaBbhPVncyrhn6.root")
        attr.put(Params.Password, "vLCfT9KIHkTonNft")
        attr.put(Params.Host, "gateway01.ap-northeast-1.prod.aws.tidbcloud.com")
        attr.put(Params.Port, "4000")
        //attr.put(Params.SSLMode, "disabled")
        MySqlConnection.createAuthedConnection(attr)
    }

}