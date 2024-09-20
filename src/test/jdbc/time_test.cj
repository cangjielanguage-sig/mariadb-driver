package cjmd.test.jdbc

import std.unittest.*
import std.unittest.testmacro.*
import cjmd.jdbc.Time
@Test
public class Test {


    @TestCase
    public func case1(){
        var str = "12:09:02";
        var time = Time.valueOf(str)
        println(time.toString())
    }


}