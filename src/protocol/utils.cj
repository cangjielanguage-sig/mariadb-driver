/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol

import std.io.*
import std.collection.*
import encoding.hex.*

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

protected func toHexStringWithPrefix(inputStream: InputStream): String {
    let buffer = Array<Byte>(1024, repeat: 0)
    var len = inputStream.read(buffer)
    if(len == 0) {
        return "''"
    }
    let builder = StringBuilder()
    builder.append("0x")
    do {
        builder.append(toHexString(buffer.slice(0, len)))
        len = inputStream.read(buffer)
    } while (len != 0)
    return builder.toString()
}