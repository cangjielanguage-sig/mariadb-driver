/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.response

import std.io.*
import mysql.protocol.*

/*
* MySQL Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_packets.html
*/
protected open class CommonResponse {

    protected let length: UInt32

    protected let number: UInt8

    internal init(length: UInt32, buffer: ByteBuffer) {
        this.length = length
        this.number = buffer.readFix1Integer()
    }

}

