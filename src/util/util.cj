/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mysql.util

import std.io.*
import std.collection.*
import std.database.sql.*
import encoding.hex.*

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