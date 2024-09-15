/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.connection.test


import std.unittest.*
import std.unittest.testmacro.*
import cjmd.*
import std.database.sql.*
@Test
public class ConnectionTest {

    @TestCase
    public func case1() {
        var driver = DriverManager.getDriver("mysql").getOrThrow()
        var property1 = (ConnectionOption.Username, "yesokim")
        var property2 = (ConnectionOption.Password, "yesokim")
        // var property1 = (ConnectionOption.Username, "root")
        // var property2 = (ConnectionOption.Password, "MySql123!")
        var property3 = (ConnectionOption.Database, "test")
        var property4 = (ConnectionOption.SSLMode, "disabled")
        var dataSource = driver.open("mysql://localhost:3306", [property1,property2,property3,property4])
        var connection =  dataSource.connect()
    }

}
