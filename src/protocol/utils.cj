/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.time.DateTime
import std.time.TimeZone
import std.io.ByteBuffer
import std.io.InputStream
import encoding.hex.toHexString
import std.collection.ArrayList


/*
 * true -> 1, false -> 0
 */
protected func toInteger(value: Bool): UInt8 {
    match (value) {
        case true => 1
        case false => 0
    }
}

protected func toBool(value: String): Bool {
    match (value) {
        case "1" => return true
        case "0" => return false
        case _ => throw IllegalArgumentException("parse string to bool faild")
    }
}

/*
* 将字符串转换为以0字节结尾的数组
*/
protected func toNullTerminated(val: String): (Array<Byte>, Int64) {
    let buf = ArrayList<Byte>(val.size + 1)
    buf.appendAll(val.toArray())
    buf.append(0)
    return (buf.toArray(), buf.size)
}

/*
 * 从流的当前位置读取一个长度编码的二进制字符串
 * 设第一个字节值为x
 * x <= 0xfa: 第一个字节值即为数据的真实长度
 * x = 0xfb: 空值数据，数据的真实长度为零
 * x = 0xfc: 后续额外2个字节标识了数据的真实长度
 * x = 0xfd: 后续额外3个字节标识了数据的真实长度
 * x = 0xfe: 后续额外8个字节标识了数据的真实长度
 * x = 0xff: 表示该数据包为 1 个 ERR_Packet
 * return:
 * None 表示数据库Null值
 */
protected func readLengthEncodedString(stream: InputStream): ?String {
    match(readLengthEncodedStringRaw(stream)) {
        case None => return None
        case Some(v) => return String.fromUtf8(v)
    }
}

protected func readLengthEncodedStringRaw(stream: InputStream): ?Array<Byte> {
    match (readLengthEncodedInteger(stream)) {
        case None => return None
        case Some(length) => return readStringRaw(stream, length)
    }
}

private func readStringRaw(stream: InputStream, length: UInt64): Array<Byte> {
    if(length == 0) {
        return []
    }
    let data = Array<Byte>(Int64(length), repeat: 0)
    stream.read(data)
    return data
}

/*
 * 从流的当前位置读取一个长度编码的二进制整数
 * 设第一个字节值为x
 * x <= 0xfa: 第一个字节值即为实际数据
 * x = 0xfb: 表示数据库空数据
 * x = 0xfc: 后续额外2个字节为实际数据
 * x = 0xfd: 后续额外3个字节为实际数据
 * x = 0xfe: 后续额外8个字节为实际数据
 * x = 0xff: 表示该数据包为 1 个 ERR_Packet
 */

protected func readLengthEncodedInteger(stream: InputStream): ?UInt {
    match (readLengthEncodedIntegerRaw(stream)) {
        case None => return None
        case Some(v) => UInt64.fromLittleEndian(v)
    }
}

protected func readLengthEncodedIntegerRaw(stream: InputStream): ?Array<Byte> {
    let single = Array<Byte>(1, repeat: 0)
    if (stream.read(single) == 0) {
        throw IllegalArgumentException("read a length encoded integer failed")
    }
    let flag = single[0]
    match (flag) {
        case 0xFB => return None
        case 0xFC =>
            let buffer = Array<Byte>(2, repeat: 0)
            stream.read(buffer)
            return buffer
        case 0xFD =>
            let buffer = Array<Byte>(3, repeat: 0)
            stream.read(buffer)
            return buffer
        case 0xFE =>
            let buffer = Array<Byte>(8, repeat: 0)
            stream.read(buffer)
            return buffer
        case 0xFF => throw InvalidPacketException("This packet is Error packet")
        case _ => return single
    }
}


/*
 * 整数转LengthEncodedInteger
 */
protected func toLengthEncoded(value: UInt): Array<Byte> {
    let buf = ArrayList<Byte>()
    if (value < 0xFB) {
        buf.append(UInt8(value))
    } else if (value < UInt64(1 << 16)) {
        buf.append(0xFC)
        buf.appendAll(UInt16(value).toLittleEndian())
    } else if (value < UInt64(1 << 24)) {
        buf.append(0xFD)
        buf.appendAll(UInt32(value).toLittleEndian().slice(0, 3))
    } else {
        buf.append(0xFE)
        buf.appendAll(value.toLittleEndian())
    }
    return buf.toArray()
}


/*
 * 字符串转LengthEncodedString
 */
protected func toLengthEncoded(value: ?String): Array<Byte> {
    match (value) {
        case None => return [0xFB]
        case Some(v) =>
            let buf = ArrayList<Byte>()
            if (v.size <= 0xFA) {
                buf.append(UInt8(v.size))
                buf.appendAll(v.toArray())
            } else if (v.size <= (1 << 16)) {
                buf.append(0xFC)
                buf.appendAll(UInt16(v.size).toLittleEndian())
                buf.appendAll(v.toArray())
            } else if (v.size <= (1 << 24)) {
                buf.append(0xFD)
                buf.appendAll(UInt32(v.size).toLittleEndian().slice(0, 3))
                buf.appendAll(v.toArray())
            } else {
                buf.append(0xFE)
                buf.appendAll(UInt64(v.size).toLittleEndian())
                buf.appendAll(v.toArray())
            }
            buf.toArray()
    }
}

/*
 * DateTime转二进制协议Date
 */
protected func toBinaryDate(dateTime: DateTime): Array<Byte> {
    let buf = ArrayList<Byte>(5)
    buf.append(4)
    buf.appendAll(UInt16(dateTime.year).toLittleEndian())
    buf.append(UInt8(dateTime.month.value()))
    buf.append(UInt8(dateTime.dayOfMonth))
    return buf.toArray()
}

/*
 * DateTime转二进制协议Time
 */
@OverflowWrapping
protected func toBinaryTime(dateTime: DateTime): Array<Byte> {
    let buf = ArrayList<Byte>(9)
    buf.append(8)
    buf.append(0x00)
    buf.appendAll([0x00,0x00,0x00,0x00])
    buf.append(UInt8(dateTime.hour))
    buf.append(UInt8(dateTime.minute))
    buf.append(UInt8(dateTime.second))
    return buf.toArray()
}

/*
 * DateTime转二进制协议DateTime或Timestamp
 */
@OverflowWrapping
protected  func toBinaryDateTime(dateTime: DateTime): Array<Byte> {
    var buf = ArrayList<Byte>(8)
    buf.append(7)
    buf.appendAll(UInt16(dateTime.year).toLittleEndian())
    buf.append(UInt8(dateTime.month.value()))
    buf.append(UInt8(dateTime.dayOfMonth))
    buf.append(UInt8(dateTime.hour))
    buf.append(UInt8(dateTime.minute))
    buf.append(UInt8(dateTime.second))
    return buf.toArray()
}


/*
 * MySql二进制转DateTime
 */
protected func dateTimeToDateTime(data: Array<Byte>): ?DateTime {
    let stream = toInputStream(data)
    let single = Array<Byte>(1, repeat: 0)
    stream.read(single)
    let year = Array<Byte>(2, repeat: 0)
    let month = Array<Byte>(1, repeat: 0)
    let day = Array<Byte>(1, repeat: 0)
    let hour = Array<Byte>(1, repeat: 0)
    let minute = Array<Byte>(1, repeat: 0)
    let second = Array<Byte>(1, repeat: 0)
    let micorSecond = Array<Byte>(4, repeat: 0)
    match (single[0]) {
        case 0 => return None
        case 4 =>
            stream.read(year)
            stream.read(month)
            stream.read(day)
            let year = UInt16.fromLittleEndian(year)
            let month = UInt8.fromLittleEndian(month)
            let day = UInt8.fromLittleEndian(day)
            return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day), timeZone: TimeZone.UTC)
        case 7 =>
            stream.read(year)
            stream.read(month)
            stream.read(day)
            stream.read(hour)
            stream.read(minute)
            stream.read(second)
            let year = UInt16.fromLittleEndian(year)
            let month = UInt8.fromLittleEndian(month)
            let day = UInt8.fromLittleEndian(day)
            let hour = UInt8.fromLittleEndian(hour)
            let minute = UInt8.fromLittleEndian(minute)
            let second = UInt8.fromLittleEndian(second)
            return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day), hour: Int64(hour),
                minute: Int64(minute), second: Int64(second), timeZone: TimeZone.Local)
        case 11 =>
            stream.read(year)
            stream.read(month)
            stream.read(day)
            stream.read(hour)
            stream.read(minute)
            stream.read(second)
            stream.read(micorSecond)
            let year = UInt16.fromLittleEndian(year)
            let month = UInt8.fromLittleEndian(month)
            let day = UInt8.fromLittleEndian(day)
            let hour = UInt8.fromLittleEndian(hour)
            let minute = UInt8.fromLittleEndian(minute)
            let second = UInt8.fromLittleEndian(second)
            let micorSecond = UInt32.fromLittleEndian(micorSecond)
            return DateTime.of(
                year: Int64(year),
                month: Int64(month),
                dayOfMonth: Int64(day),
                hour: Int64(hour),
                minute: Int64(minute),
                second: Int64(second),
                nanosecond: Int64(micorSecond),
                timeZone: TimeZone.Local
            )
        case _ => throw InvalidPacketException("")
    }
}

/*
 * MySql二进制转DateTime
 */
protected func timeToDateTime(data: Array<Byte>): ?DateTime {
    let stream = toInputStream(data)
    let single = Array<Byte>(1, repeat: 0)
    stream.read(single)
    let negative = Array<Byte>(1, repeat: 0)
    let day = Array<Byte>(4, repeat: 0)
    let hour = Array<Byte>(1, repeat: 0)
    let minute = Array<Byte>(1, repeat: 0)
    let second = Array<Byte>(1, repeat: 0)
    let micorSecond = Array<Byte>(4, repeat: 0)
    match (single[0]) {
        case 0 => return None
        case 8 =>
            stream.read(negative)
            stream.read(day)
            stream.read(hour)
            stream.read(minute)
            stream.read(second)
            //var negative = littleEndianToUInt64(negativeArray)
            //var day = littleEndianToUInt64(dayArray)
            let hour = UInt8.fromLittleEndian(hour)
            let minute = UInt8.fromLittleEndian(minute)
            let second = UInt8.fromLittleEndian(second)
            return DateTime.of(
                year: 1970,
                month: 1,
                dayOfMonth: 1,
                hour: Int64(hour),
                minute: Int64(minute),
                second: Int64(second),
                timeZone: TimeZone.UTC
            )
        case 12 =>
            stream.read(negative)
            stream.read(day)
            stream.read(hour)
            stream.read(minute)
            stream.read(second)
            stream.read(micorSecond)
            //var negative = littleEndianToUInt64(negativeArray)
            //var day = littleEndianToUInt64(dayArray)
            let hour = UInt8.fromLittleEndian(hour)
            let minute = UInt8.fromLittleEndian(minute)
            let second = UInt8.fromLittleEndian(second)
            let micorSecond = UInt32.fromLittleEndian(micorSecond)
            return DateTime.of(
                year: 1970,
                month: 1,
                dayOfMonth: 1,
                hour: Int64(hour),
                minute: Int64(minute),
                second: Int64(second),
                nanosecond: Int64(micorSecond),
                timeZone: TimeZone.Local
            )
        case _ => throw InvalidPacketException("")
    }
}

/*
 * InputStream转Array
 */
protected func toArray(inputStream: InputStream): Array<Byte> {
    var buffer = Array<Byte>(1024, repeat: 0)
    var len = inputStream.read(buffer)
    var buf = ArrayList<Byte>()
    do {
        buf.appendAll(buffer.slice(0,len))
        len = inputStream.read(buffer)
    } while (len != 0)
    return buf.toArray()
}

/*
 * Array转InputStream
 */
protected func toInputStream(buffer: Array<Byte>): InputStream{
    return ByteBuffer(buffer)
}

/*
 * Array转二进制字符串，以0x开头
 */
protected func to0xString(buffer: Array<Byte>): String {
    if(buffer.size == 0) {
        return "''"
    }
    return "0x${toHexString(buffer)}"
}

/*
 * 无事可做的函数，用于压制编译器报警
 */
 protected func nothingTodo(v: Any): Any {
    return v
 }