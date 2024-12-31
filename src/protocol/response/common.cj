/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol.response

import std.io.ByteBuffer
import mysql.protocol.FixedByteReader
import mysql.protocol.InvalidPacketException
/*
* MySQL Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_packets.html
*/
protected open class CommonResponse {

    protected let length: UInt32

    protected let number: UInt8

    internal init(length: UInt32, buffer: ByteBuffer) {
        this.length = length
        this.number = buffer.readOneByte()
    }

}

