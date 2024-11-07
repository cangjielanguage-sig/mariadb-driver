/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.time.DateTime
import std.time.TimeZone
import std.io.ByteBuffer
import std.collection.ArrayList

protected interface BinaryDate {

    func toBinaryDate(): Array<Byte>

    func toBinaryTime(): Array<Byte>

    func toBinaryDateTime(): Array<Byte>

    static func fromBinaryDateTime(data: Array<Byte>): ?DateTime

    static func fromBinaryTime(data: Array<Byte>): ?DateTime
}

extend DateTime <: BinaryDate {
    
    public func toBinaryDate(): Array<Byte> {
        let buf = ArrayList<Byte>(5)
        buf.append(4)
        buf.appendAll(UInt16(year).toLittleEndian())
        buf.append(UInt8(month.value()))
        buf.append(UInt8(dayOfMonth))
        return buf.toArray()
    }

    @OverflowWrapping
    public func toBinaryTime(): Array<Byte> {
        let buf = ArrayList<Byte>(9)
        buf.append(8)
        buf.append(0x00)
        buf.appendAll([0x00, 0x00, 0x00, 0x00])
        buf.append(UInt8(hour))
        buf.append(UInt8(minute))
        buf.append(UInt8(second))
        return buf.toArray()
    }

    @OverflowWrapping
    public func toBinaryDateTime(): Array<Byte> {
        var buf = ArrayList<Byte>(8)
        buf.append(7)
        buf.appendAll(UInt16(year).toLittleEndian())
        buf.append(UInt8(month.value()))
        buf.append(UInt8(dayOfMonth))
        buf.append(UInt8(hour))
        buf.append(UInt8(minute))
        buf.append(UInt8(second))
        return buf.toArray()
    }

    public static func fromBinaryDateTime(data: Array<Byte>): ?DateTime {
        let buffer = ByteBuffer(data)
        match (buffer.readOneByte()) {
            case 0 => return None
            case 4 =>
                let year = UInt16.fromLittleEndian(buffer.readBytes(2))
                let month = UInt8.fromLittleEndian(buffer.readBytes(1))
                let day = UInt8.fromLittleEndian(buffer.readBytes(1))
                return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day),
                    timeZone: TimeZone.UTC)
            case 7 =>
                let year = UInt16.fromLittleEndian(buffer.readBytes(2))
                let month = UInt8.fromLittleEndian(buffer.readBytes(1))
                let day = UInt8.fromLittleEndian(buffer.readBytes(1))
                let hour = UInt8.fromLittleEndian(buffer.readBytes(1))
                let minute = UInt8.fromLittleEndian(buffer.readBytes(1))
                let second = UInt8.fromLittleEndian(buffer.readBytes(1))
                return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day), hour: Int64(hour),
                    minute: Int64(minute), second: Int64(second), timeZone: TimeZone.Local)
            case 11 =>
                let year = UInt16.fromLittleEndian(buffer.readBytes(2))
                let month = UInt8.fromLittleEndian(buffer.readBytes(1))
                let day = UInt8.fromLittleEndian(buffer.readBytes(1))
                let hour = UInt8.fromLittleEndian(buffer.readBytes(1))
                let minute = UInt8.fromLittleEndian(buffer.readBytes(1))
                let second = UInt8.fromLittleEndian(buffer.readBytes(1))
                let micorSecond = UInt32.fromLittleEndian(buffer.readBytes(4))
                return DateTime.of(year: Int64(year),month: Int64(month),dayOfMonth: Int64(day),hour: Int64(hour),
                    minute: Int64(minute),second: Int64(second),nanosecond: Int64(micorSecond),timeZone: TimeZone.Local)
            case _ => throw InvalidPacketException("")
        }
    }

    public static func fromBinaryTime(data: Array<Byte>): ?DateTime {
        let buffer = ByteBuffer(data)
        match (buffer.readOneByte()) {
            case 0 => return None
            case 8 =>
                let _ = buffer.readBytes(1) //negative
                let _ = buffer.readBytes(4) //day
                let hour = UInt8.fromLittleEndian(buffer.readBytes(1))
                let minute = UInt8.fromLittleEndian(buffer.readBytes(1))
                let second = UInt8.fromLittleEndian(buffer.readBytes(1))
                return DateTime.of(year: 1970,month: 1,dayOfMonth: 1, hour: Int64(hour),
                    minute: Int64(minute),second: Int64(second),timeZone: TimeZone.UTC)
            case 12 =>
                let _ = buffer.readBytes(1) //negative
                let _ = buffer.readBytes(4) //day
                let hour = UInt8.fromLittleEndian(buffer.readBytes(1))
                let minute = UInt8.fromLittleEndian(buffer.readBytes(1))
                let second = UInt8.fromLittleEndian(buffer.readBytes(1))
                let micorSecond = UInt32.fromLittleEndian(buffer.readBytes(4))
                return DateTime.of(year: 1970, month: 1, dayOfMonth: 1, hour: Int64(hour), minute: Int64(minute),
                    second: Int64(second), nanosecond: Int64(micorSecond), timeZone: TimeZone.Local
                )
            case _ => throw InvalidPacketException("")
        }
    }
}
