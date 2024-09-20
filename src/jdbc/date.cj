/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

import std.time.DateTime
import std.time.DateTimeFormat

public class Date <: ToString {

    private var _dateTime: DateTime

    public prop dateTime: DateTime {
        get() {
            _dateTime
        }
    }

    public init(year: Int64, month: Int64, day: Int64) {
        _dateTime = DateTime.of(year: year, month: month, dayOfMonth: day)
    }
    
    public init(timestamp: Int64) {
        _dateTime = DateTime.fromUnixTimeStamp(timestamp * Duration.second)
    }

    public init(dateTime: DateTime) {
        _dateTime = dateTime
    }

    public func toString(): String {
        return _dateTime.toString("yyyy-MM-dd")
    }

    public func toString(foramt: String): String {
        return _dateTime.toString(foramt)
    }

    public static func valueOf(s: String): Date {
        return Date(DateTime.parse(s, "yyyy-MM-dd"))
    }

}