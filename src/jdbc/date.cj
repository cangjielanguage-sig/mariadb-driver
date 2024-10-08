/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

import std.time.{DateTime, TimeZone, DayOfWeek, Month, DateTimeFormat}

public class Date <: ToString & Comparable<Date> & Hashable {

    private var delegate: DateTime

    public init(year: Int64, month: Int64, day: Int64, timeZone!: TimeZone = TimeZone.Local) {
        delegate = DateTime.of(year: year, month: month, dayOfMonth: day, timeZone: timeZone)
    }

    public prop year: Int64 {
        get() {
            delegate.year
        }
    }

    public prop month: Month {
        get() {
            delegate.month
        }
    }

    public prop monthValue: Int64 {
        get() {
            delegate.monthValue
        }
    }

    public prop dayOfMonth: Int64 {
        get() {
            delegate.dayOfMonth
        }
    }

    public prop dayOfWeek: DayOfWeek {
        get() {
            delegate.dayOfWeek
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

    public func addYears(years: Int64): Date {
        return fromDateTime(delegate.addYears(years))
    }

    public func addMonths(months: Int64): Date {
        return fromDateTime(delegate.addMonths(months))
    }

    public func addDays(days: Int64): Date {
        return fromDateTime(delegate.addDays(days))
    }

    public override func hashCode(): Int64 {
        return delegate.hashCode()
    }

    public override func compare(date: Date): Ordering {
        return delegate.compare(date.delegate)
    }

    public operator func != (date: Date): Bool {
        return delegate != date.delegate
    }

    public operator func == (date: Date): Bool {
        return delegate == date.delegate
    }

    public operator func > (date: Date): Bool {
        return delegate > date.delegate
    }

    public operator func < (date: Date): Bool {
        return delegate < date.delegate
    }

    public operator func <= (date: Date): Bool {
        return delegate <= date.delegate
    }

    public operator func >= (date: Date): Bool {
        return delegate >= date.delegate
    }

    public override func toString(): String {
        return delegate.toString("yyyy-MM-dd")
    }

    public func toString(foramt: String): String {
        return delegate.toString(foramt)
    }

    public static func fromDateTime(dateTime: DateTime): Date {
        return Date(dateTime.year, dateTime.monthValue, dateTime.dayOfMonth, timeZone: dateTime.zone)
    }

    public static func now(timeZone!: TimeZone = TimeZone.Local): Date {
        return fromDateTime(DateTime.now(timeZone: timeZone))
    }

}