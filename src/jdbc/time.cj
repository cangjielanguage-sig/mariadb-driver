/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

import std.time.DateTime
import std.convert.*
public class Time <: ToString {

    private var _dateTime: DateTime

    public prop dateTime: DateTime {
        get() {
            _dateTime
        }
    }

    /*
    * 通过时分秒进行构造
    */
    public init(hour: Int64, minute: Int64, second: Int64) {
        _dateTime = DateTime.of(year: 1970, month: 1, dayOfMonth: 1, hour: hour, minute: minute, second: second)
    }


    /*
    * 通过DateTime实例构造
    */
    public init(dateTime: DateTime) {
        _dateTime = dateTime
    }

    /*
    * 通过Unix时间戳构造
    */
    public init(time: Int64) {
        _dateTime = DateTime.fromUnixTimeStamp(time * Duration.second)
    }

    public override func toString(): String {
        _dateTime.toString("hh:mm:ss")
    }

    public func toString(foramt: String): String {
        return _dateTime.toString(foramt)
    }


    public static func valueOf(time: String): Time{
        var firstColon = time.indexOf(':').getOrThrow({=>IllegalArgumentException()})
        var secondColon = time.indexOf(':', firstColon + 1).getOrThrow({=>IllegalArgumentException()})
        if(firstColon > 0 && secondColon > 0 && secondColon < time.size - 1) {
            var hour = Int64.parse(time[0..firstColon])
            var minute = Int64.parse(time[(firstColon + 1) .. secondColon])
            var second = Int64.parse(time[(secondColon + 1) .. time.size])
             return Time(hour, minute, second);
        }else {
            throw IllegalArgumentException()
        }
    }

}