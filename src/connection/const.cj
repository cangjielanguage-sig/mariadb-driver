/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
protected package mysql.connection

import std.io.*
import stdx.encoding.hex.*

//mysql datetime类型的默认格式
protected const DB_DATE_TIME_FORMAT: String = "yyyy-MM-dd HH:mm:ss"

// //mysql date类型的默认格式
// protected const DB_DATE_FORMAT: String = "yyyy-MM-dd"

// //mysql time类型的默认格式
// protected const DB_TIME_FORMAT: String = "HH:mm:ss"

//mysql time类型转DateTime的前缀
protected const DB_TIME_PREFIX: String = "1970-01-01 "

protected const DB_DATE_SUFFIX: String = " 00:00:00"


protected func escapeString(value: String): String {
    let builder = StringBuilder()
    builder.append("'")
    for(i in value.toRuneArray()) {
        match (i) {
            case r'\n' => builder.append("\\n")
            case r'\r' => builder.append("\\r")
            case r'\\' => builder.append("\\\\")
            case r'\'' => builder.append("\'\'")
            case r'"' => builder.append("\"")
            case _ => builder.append(i)
            }
        }
        builder.append("'")
        return builder.toString()
}

protected func toHexStringWithPrefix(inputStream: InputStream): String {
    let buffer = Array<Byte>(8096, repeat: 0)
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

protected func toHexStringWithPrefix(array: Array<Byte>): String {
    if(array.size == 0) {
        return "''"
    }
    return "0x${toHexString(array)}"
}

protected func toArray(inputStream: InputStream): Array<Byte> {
    let buffer = Array<Byte>(1024, repeat: 0)
    let bytes = ByteBuffer()
    var len = inputStream.read(buffer)
    do {
        bytes.write(buffer.slice(0, len))
        len = inputStream.read(buffer)
    } while (len != 0)
    return readToEnd(bytes)
}

extend String {


    public func toNullTerminated(): Array<Byte> {
        return this.toArray().toNullTerminated()
    }
    
}

extend Array<Byte>  {

    public func toNullTerminated(): Array<Byte> {
        let buf = Array<Byte>(this.size + 1, repeat: 0)
        this.copyTo(buf, 0, 0, this.size)
        return buf
    }

}