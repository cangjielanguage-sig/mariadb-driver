protected package cjmd.test.jdbc

import std.unittest.*
import std.unittest.testmacro.*
import cjmd.jdbc.Date
import std.time.*

@Test
public class DateTest {


    @TestCase
    public func case1(): Unit {
        println(Date.now())
        println(Date.now(timeZone: TimeZone.UTC))
    }


    @TestCase
    public func case2(): Unit {
        var now = Date.now()
        var beforeNow = now.addDays(1)
        println(now)
        println(beforeNow)
        println(beforeNow > now)
    }

}