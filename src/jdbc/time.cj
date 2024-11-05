/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc

import std.time.DateTime
import std.time.TimeZone

public class Time <: ToString & Comparable<Time> & Hashable {

    private let delegate: DateTime

    public init(hour: Int64, minute: Int64, second: Int64, timeZone!: TimeZone = TimeZone.Local) {
        delegate = DateTime.of(year: 1970, month: 1, dayOfMonth: 1, hour: hour, minute: minute, second: second, timeZone: timeZone)
    }

    public prop hour: Int64 {
        get() {
            delegate.hour
        }
    }

    public prop minute: Int64 {
        get() {
            delegate.minute
        }
    }

    public prop second: Int64 {
        get() {
            delegate.second
        }
    }

    public prop zone: TimeZone {
        get() {
            delegate.zone
        }
    }

    public prop zoneId: String {
        get() {
            delegate.zoneId
        }
    }

    public prop zoneOffset: Duration {
        get() {
            delegate.zoneOffset
        }
    }

    public func addHours(hours: Int64): Time {
        return fromDateTime(delegate.addHours(hours))
    }

    public func addMinutes(minutes: Int64): Time {
        return fromDateTime(delegate.addMinutes(minutes))
    }

    public func addSeconds(seconds: Int64): Time {
        return fromDateTime(delegate.addSeconds(seconds))
    }

    public override func hashCode(): Int64 {
        return delegate.hashCode()
    }

    public override func compare(time: Time): Ordering {
        return delegate.compare(time.delegate)
    }

    public operator func != (time: Time): Bool {
        return delegate != time.delegate
    }

    public operator func == (time: Time): Bool {
        return delegate == time.delegate
    }

    public operator func > (time: Time): Bool {
        return delegate > time.delegate
    }

    public operator func < (time: Time): Bool {
        return delegate < time.delegate
    }

    public operator func <= (time: Time): Bool {
        return delegate <= time.delegate
    }

    public operator func >= (time: Time): Bool {
        return delegate >= time.delegate
    }

    public override func toString(): String {
        return delegate.toString("HH:mm:ss")
    }

    public func toString(foramt: String): String {
        return delegate.toString(foramt)
    }

    public static func fromDateTime(dateTime: DateTime): Time {
        return Time(dateTime.hour, dateTime.minute, dateTime.second, timeZone: dateTime.zone)
    }

    public static func now(timeZone!: TimeZone = TimeZone.Local): Time {
        return fromDateTime(DateTime.now(timeZone: timeZone))
    }

}