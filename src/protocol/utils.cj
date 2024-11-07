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
 protected func nothing(v: Any): Any {
    return v
 }