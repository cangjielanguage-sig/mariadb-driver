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

    public init(dateTime: DateTime){
        _dateTime = dateTime
    }

    public init(date: String) {
        _dateTime = DateTime.parse(date)
    }

    public init(date: String, format: String) {
        _dateTime = DateTime.parse(date, format)
    }

    public func toString(): String {
        return _dateTime.toString("yyyy-MM-dd")
    }

    public func toString(format: String): String{
        return _dateTime.toString(format)
    }
}