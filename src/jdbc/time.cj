/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

import std.time.DateTime

public class Time <: ToString {

    private var _dateTime: DateTime

    public prop dateTime: DateTime {
        get() {
            _dateTime
        }
    }

    public init(dateTime: DateTime) {
        _dateTime = dateTime
    }

    public override func toString(): String {
        _dateTime.toString("hh:mm:ss")
    }

    public func toString(format: String){
        _dateTime.toString(format)
    }

}