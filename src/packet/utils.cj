/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.packet

import std.collection.ArrayList
import std.binary.*
import std.time.*
import std.io.*
import encoding.hex.*

/*
 * Bool转整数 true -> 1 false -> 0
 */
protected  func boolToInteger(value: Bool): Int8 {
    if (value) {
        return 1
    } else {
        return 0
    }
}

/*
 * 小端序字节数组转UInt64
 */
protected func littleEndianToUInt64(array: Array<Byte>): UInt64 {
    if (array.size < 1 || array.size > 8) {
        throw IllegalArgumentException("array szie must between 1 and 8")
    }
    var arr: Array<Byte> = Array<Byte>(8, item: 0x00)
    var result: UInt64 = 0;
    var i = 0;
    while (i < array.size) {
        arr[i] = array[i]
        result |= UInt64(arr[i]) << 8 * i
        i++
    }
    return result
}
/*
 * 小端序字节数组转UInt32
 */
protected func littleEndianToUInt32(array: Array<Byte>): UInt32 {
    if (array.size < 1 || array.size > 4) {
        throw IllegalArgumentException("Array size must between 1 and 4")
    }
    var arr: Array<Byte> = Array<Byte>(4, item: 0x00)
    var result: UInt32 = 0;
    var i = 0;
    while (i < array.size) {
        arr[i] = array[i]
        result |= UInt32(arr[i]) << 8 * i
        i++
    }
    return result
}

/*
 * 小端序字节数组转UInt16
 */
protected func littleEndianToUInt16(array: Array<Byte>): UInt16 {
    if (array.size < 1 || array.size > 2) {
        throw IllegalArgumentException("array szie must between 1 and 2")
    }
    var arr: Array<Byte> = [0x00, 0x00]
    var result: UInt16 = 0x00;
    var i = 0;
    while (i < array.size) {
        arr[i] = array[i]
        result |= UInt16(arr[i]) << 8 * i
        i++
    }
    return result
}

/*
 * UInt64转小端字节数组
 */
protected  func uInt64ToLittleEndian(number: UInt64): Array<Byte> {
    var buffer = Array<Byte>(8, item: 0)
    number.writeLittleEndian(buffer)
    return buffer
}


/*
 * UInt32转小端序字节数组
 */
protected func uInt32ToLittleEndian(number: UInt32): Array<Byte> {
    var buffer = Array<Byte>(4, item: 0)
    number.writeLittleEndian(buffer)
    return buffer
}

/*
 * UInt16转小端序字节数组
 */
protected  func uInt16ToLittleEndian(number: UInt16): Array<Byte> {
    var buffer = Array<Byte>(2, item: 0)
    number.writeLittleEndian(buffer)
    return buffer
}

/*
 * Float16转大端字节数组
 */
protected  func float32ToLittleEndian(number: Float32): Array<Byte> {
    var array = Array<Byte>(4, item: 0)
    number.writeLittleEndian(array)
    return array
}

/*
 * Float16转大端字节数组
 */
protected  func float64ToLittleEndian(number: Float64): Array<Byte> {
    var array = Array<Byte>(8, item: 0)
    number.writeLittleEndian(array)
    return array
}

/*
 * 小端字节数组转Float32
 */
protected  func littleEndianToFloat32(array: Array<Byte>): Float32 {
    return Float32.readLittleEndian(array)
}

/*
 * 小端字节数组转Float64
 */
protected  func littleEndianToFloat64(array: Array<Byte>): Float64 {
    return Float64.readLittleEndian(array)
}


/*
 * 从流的当前位置读取一个长度编码的二进制字符串
 * 设第一个字节值为x
 * x < 0xfb: 第一个字节值即为数据的真实长度
 * x = 0xfb: 空值数据，数据的真实长度为零
 * x = 0xfc: 后续额外2个字节标识了数据的真实长度
 * x = 0xfd: 后续额外3个字节标识了数据的真实长度
 * x = 0xfe: 后续额外8个字节标识了数据的真实长度
 * x = 0xff: 表示该数据包为 1 个 ERR_Packet
 * return:
 * None 表示数据库Null值
 */
protected func readLengthEncodedString(array: Array<Byte>): ?Array<Byte> {
    var stream = ByteArrayStream()
    stream.write(array)
    return readLengthEncodedString(stream)
}
protected func readLengthEncodedString(stream: InputStream): ?Array<Byte> {
    var single = Array<Byte>(1, item: 0)
    stream.read(single)
    var lengthFlag = single[0]
    match (lengthFlag) {
        case 0x00 => return []
        case 0xFB => return None
        case 0xFC => return readString(stream, 2)
        case 0xFD => return readString(stream, 3)
        case 0xFE => return readString(stream, 8)
        case 0xFF => throw InvalidPacketException("This packet is Error packet")
        case _ =>
            var buf = Array<Byte>(Int64(single[0]), item: 0)
            stream.read(buf)
            return buf
    }
}

protected  func readString(stream: InputStream, len: Int64): Array<Byte> {
    var buf = Array<Byte>(Int64(len), item: 0)
    stream.read(buf)
    var dataLen = littleEndianToUInt64(buf)
    var data = Array<Byte>(Int64(dataLen), item: 0)
    stream.read(data)
    return data
}

/*
 * 字符串转LengthEncodedString
 */
protected  func stringToLengthEncoded(str: ?String): Array<Byte> {
    var list = ArrayList<Byte>()
    if (str.isNone()) {
        list.append(0xFB)
    } else {
        var value = str.getOrThrow()
        if (value.size <= 0xFA) {
            list.append(UInt8(value.size))
            list.appendAll(value.toArray())
        } else if (value.size <= (2 ** 16)) {
            list.append(0xFC)
            list.appendAll(uInt16ToLittleEndian(UInt16(value.size)))
            list.appendAll(value.toArray())
        } else if (value.size <= 2 ** 24) {
            list.append(0xFD)
            list.appendAll(uInt32ToLittleEndian(UInt32(value.size)).slice(0, 3))
            list.appendAll(value.toArray())
        } else {
            list.append(0xFE)
            list.appendAll(uInt64ToLittleEndian(UInt64(value.size)))
            list.appendAll(value.toArray())
        }
    }
    return list.toArray()
}

/*
 * 从流的当前位置读取一个长度编码的二进制整数
 * 设第一个字节值为x
 * x <= 0xfa: 第一个字节值即为实际数据
 * x = 0xfc: 后续额外2个字节为实际数据
 * x = 0xfd: 后续额外3个字节为实际数据
 * x = 0xfe: 后续额外8个字节为实际数据
 * x = 0xff: 表示该数据包为 1 个 ERR_Packet
 */
protected  func readLengthEncodedInteger(stream: InputStream): Array<Byte> {
    var single = Array<Byte>(1, item: 0)
    if (stream.read(single) == 0) {
        return []
    }
    var lengthFlag = single[0]
    match (lengthFlag) {
        case 0xfc =>
            var buffer = Array<Byte>(2, item: 0)
            stream.read(buffer)
            return buffer
        case 0xfd =>
            var buffer = Array<Byte>(3, item: 0)
            stream.read(buffer)
            return buffer
        case 0xfe =>
            var buffer = Array<Byte>(8, item: 0)
            stream.read(buffer)
            return buffer
        case 0xff => throw InvalidPacketException("This packet is Error packet")
        case _ => return single
    }
}

/*
 * 整数转LengthEncodedInteger
 */
protected  func integerToLengthEncoded(value: UInt64): Array<Byte> {
    var list = ArrayList<Byte>()
    if (value < 0xFB) {
        list.append(UInt8(value))
    } else if (value < UInt64(2 ** 16)) {
        list.append(0xFC)
        list.appendAll(uInt16ToLittleEndian(UInt16(value)))
    } else if (value < UInt64(2 ** 24)) {
        list.append(0xFD)
        list.appendAll(uInt32ToLittleEndian(UInt32(value)).slice(0, 3))
    } else {
        list.append(0xFE)
        list.appendAll(uInt64ToLittleEndian(value))
    }
    return list.toArray()
}

/*
 * DateTime转二进制协议Date
 */
protected  func dateTimeToProtocolBinaryDate(dateTime: DateTime): Array<Byte> {
    var list = ArrayList<Byte>(5)
    list.append(4)
    list.appendAll(uInt16ToLittleEndian(UInt16(dateTime.year)))
    list.append(UInt8(dateTime.month.value()))
    list.append(UInt8(dateTime.dayOfMonth))
    return list.toArray()
}

/*
 * DateTime转二进制协议DateTime或Timestamp
 */
@OverflowWrapping
protected  func dateTimeToProtocolBinaryDateTime(dateTime: DateTime): Array<Byte> {
    var list = ArrayList<Byte>(8)
    list.append(7)
    list.appendAll(uInt16ToLittleEndian(UInt16(dateTime.year)))
    list.append(UInt8(dateTime.month.value()))
    list.append(UInt8(dateTime.dayOfMonth))
    list.append(UInt8(dateTime.hour))
    list.append(UInt8(dateTime.minute))
    list.append(UInt8(dateTime.second))
    return list.toArray()
}

/*
 * DateTime转二进制协议Time
 */
@OverflowWrapping
protected func dateTimeToProtocolBinaryTime(dateTime: DateTime): Array<Byte> {
    var list = ArrayList<Byte>(9)
    list.append(8)
    list.append(0x00)
    //list.appendAll(uInt32ToLittleEndian(UInt32(dateTime.dayOfYear)))
    list.appendAll([0x00,0x00,0x00,0x00])
    list.append(UInt8(dateTime.hour))
    list.append(UInt8(dateTime.minute))
    list.append(UInt8(dateTime.second))
    return list.toArray()
}

/*
 * MySql二进制转DateTime
 */
protected  func binaryDateTimeToDateTime(data: Array<Byte>): ?DateTime {
    var stream = ByteArrayStream(data.size)
    stream.write(data)
    var single = Array<Byte>(1, item: 0)
    stream.read(single)
    var yearArray = Array<Byte>(2, item: 0)
    var monthArray = Array<Byte>(1, item: 0)
    var dayArray = Array<Byte>(1, item: 0)
    var hourArray = Array<Byte>(1, item: 0)
    var minuteArray = Array<Byte>(1, item: 0)
    var secondArray = Array<Byte>(1, item: 0)
    var micorSecondArray = Array<Byte>(4, item: 0)
    match (single[0]) {
        case 0 => return None
        case 4 =>
            stream.read(yearArray)
            stream.read(monthArray)
            stream.read(dayArray)
            var year = littleEndianToUInt64(yearArray)
            var month = littleEndianToUInt64(monthArray)
            var day = littleEndianToUInt64(dayArray)
            return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day), timeZone: TimeZone.UTC)
        case 7 =>
            stream.read(yearArray)
            stream.read(monthArray)
            stream.read(dayArray)
            stream.read(hourArray)
            stream.read(minuteArray)
            stream.read(secondArray)
            var year = littleEndianToUInt64(yearArray)
            var month = littleEndianToUInt64(monthArray)
            var day = littleEndianToUInt64(dayArray)
            var hour = littleEndianToUInt64(hourArray)
            var minute = littleEndianToUInt64(minuteArray)
            var second = littleEndianToUInt64(secondArray)
            return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day), hour: Int64(hour),
                minute: Int64(minute), second: Int64(second), timeZone: TimeZone.Local)
        case 11 =>
            stream.read(yearArray)
            stream.read(monthArray)
            stream.read(dayArray)
            stream.read(hourArray)
            stream.read(minuteArray)
            stream.read(secondArray)
            stream.read(micorSecondArray)
            var year = littleEndianToUInt64(yearArray)
            var month = littleEndianToUInt64(monthArray)
            var day = littleEndianToUInt64(dayArray)
            var hour = littleEndianToUInt64(hourArray)
            var minute = littleEndianToUInt64(minuteArray)
            var second = littleEndianToUInt64(secondArray)
            var micorSecond = littleEndianToUInt64(micorSecondArray)
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
protected func binaryTimeToDateTime(data: Array<Byte>): ?DateTime {
    var stream = ByteArrayStream(data.size)
    stream.write(data)
    var single = Array<Byte>(1, item: 0)
    stream.read(single)
    var negativeArray = Array<Byte>(1, item: 0)
    var dayArray = Array<Byte>(4, item: 0)
    var hourArray = Array<Byte>(1, item: 0)
    var minuteArray = Array<Byte>(1, item: 0)
    var secondArray = Array<Byte>(1, item: 0)
    var micorSecondArray = Array<Byte>(4, item: 0)
    match (single[0]) {
        case 0 => return None
        case 8 =>
            stream.read(negativeArray)
            stream.read(dayArray)
            stream.read(hourArray)
            stream.read(minuteArray)
            stream.read(secondArray)
            //var negative = littleEndianToUInt64(negativeArray)
            //var day = littleEndianToUInt64(dayArray)
            var hour = littleEndianToUInt64(hourArray)
            var minute = littleEndianToUInt64(minuteArray)
            var second = littleEndianToUInt64(secondArray)
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
            stream.read(negativeArray)
            stream.read(dayArray)
            stream.read(hourArray)
            stream.read(minuteArray)
            stream.read(secondArray)
            stream.read(micorSecondArray)
            //var negative = littleEndianToUInt64(negativeArray)
            //var day = littleEndianToUInt64(dayArray)
            var hour = littleEndianToUInt64(hourArray)
            var minute = littleEndianToUInt64(minuteArray)
            var second = littleEndianToUInt64(secondArray)
            var micorSecond = littleEndianToUInt32(micorSecondArray)
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
protected func inputStreamToArray(inputStream: InputStream): Array<Byte> {
    var buffer = Array<Byte>(1024, item: 0)
    var len = inputStream.read(buffer)
    var list = ArrayList<Byte>()
    do {
        list.appendAll(buffer.slice(0,len))
        len = inputStream.read(buffer)
    } while (len != 0)
    return list.toArray()
}

/*
 * Array转InputStream
 */
protected func arrayToInputStream(array: Array<Byte>): InputStream {
    var stream = ByteArrayStream(array.size)
    stream.write(array)
    return stream
}

/*
 * Array转二进制字符串，以0x开头
 */
protected func arrayToHexString(array: Array<Byte>): String {
    if(array.size == 0){
        return "''"
    }
    var builder = StringBuilder()
    builder.append("0x")
    builder.append(toHexString(array))
    return builder.toString()
}

/*
 * 无事可做的函数，用于压制编译器报警
 */
 protected func nothingTodo(v: Any): Any {
    return v
 }