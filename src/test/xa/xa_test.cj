/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.test.xa


import std.unittest.*
import std.unittest.testmacro.*
import std.collection.HashMap
import mysql.xa.*

@Test
public class XATest {


    @TestCase
    public func case1(): Unit {
        let map = HashMap<String, String>()
        map.put("host", "localhost")
        map.put("username", "root")
        map.put("port", "3306")
        map.put("password", "123456")
        map.put("ssl.mode", "disabled")
        let xaResource = MySqlXaResouce(map)
        let xid = MySqlXid("yesokim".toArray(), branchQualifier: "brach1".toArray())
        xaResource.start(xid)
        xaResource.end(xid)
        xaResource.prepare(xid)
        let xids = xaResource.revocer()
        for(xid in xids) {
            println(String.fromUtf8(xid.globalTransactionId))
            println(String.fromUtf8(xid.branchQualifier))
            println(xid.formatId)
        }
        xaResource.commit(xid)
        xaResource.close()
    }


}