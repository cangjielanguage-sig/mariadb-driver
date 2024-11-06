/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol.response

import std.io.ByteBuffer
import mysqlclient4cj.protocol.InvalidPacketException
/*
* MySQL Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_packets.html
*/
protected open class CommonResponse {

    protected let length: UInt32

    protected let number: UInt8

    internal init(length: UInt32, buffer: ByteBuffer) {
        this.length = length
        let single = Array<Byte>(1, repeat: 0)
        if (buffer.read(single) == 0) {
            throw InvalidPacketException("This package is not a mysql package: read number failed")
        }
        this.number = single[0]
    }

}

