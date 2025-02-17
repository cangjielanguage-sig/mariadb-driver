/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol

import std.io.*
import std.collection.*

/*
 * InputStream转Array
 */
protected func toArray(inputStream: InputStream): Array<Byte> {
    let buffer = Array<Byte>(1024, repeat: 0)
    let buf = ArrayList<Byte>()
    var len = inputStream.read(buffer)
    do {
        buf.add(all: buffer.slice(0,len))
        len = inputStream.read(buffer)
    } while (len != 0)
    return buf.toArray()
}

/*
 * 无事可做的函数，用于压制编译器报警
 */
 protected func nothing(v: Any): Any {
    return v
 }