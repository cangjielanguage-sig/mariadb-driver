protected package mysqlclient4cj.test.jdbc

import std.unittest.*
import std.unittest.testmacro.*
import mysqlclient4cj.jdbc.Time
import std.time.*
@Test
public class Test {

    @TestCase
    public func case1(): Unit {
        println(Time.now())
        println(Time.now(timeZone: TimeZone.UTC))
    }

    @TestCase
    public func case3(): Unit {
        var now = Time.now()
        var afterNow = now.addHours(1)
        println("${now.hour}:${now.minute}:${now.second}")
        println("${afterNow.hour}:${afterNow.minute}:${afterNow.second}")
        println(now)
        println(afterNow)
        println(afterNow > now)
    }

    @TestCase
    public func case4(): Unit {
        var time = Time(23,35,5)
        var afterTime = time.addHours(1)
        println(time)
        println(afterTime)
        println(afterTime > time)
    }

}