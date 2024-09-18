/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.protocol

import std.log.*
import std.collection.*
import std.console.*
import std.io.*

/*
* MySQL Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_packets.html
*/
protected open class CommonPacket {

    internal static const LENGTH_SIZE: Int64 = 3

    internal static const NUMBER_SIZE: Int64 = 1

    //通用头部长度
    internal static const HEADER_SIZE: Int64 = LENGTH_SIZE + NUMBER_SIZE;

    //子包长度
    internal var _length: UInt32

    //子包编号
    internal var _number: UInt8

    // consturct for response packet
    protected init(stream: InputStream) {
        var length = Array<Byte>(3, repeat: 0)
        if (stream.read(length) == 0) {
            throw InvalidPacketException("This package is not a mysql package: read length failed")
        }
        _length = littleEndianToUInt32(length)
        var single = Array<Byte>(1, repeat: 0)
        if (stream.read(single) == 0) {
            throw InvalidPacketException("This package is not a mysql package: read number failed")
        }
        _number = single[0]
    }
    //constructor for request packet
    protected CommonPacket(length: UInt32, number: UInt8) {
        this._length = length
        this._number = number
    }

    protected prop length: UInt32 {
        get() {
            _length
        }
    }
    
    protected prop number: UInt8 {
        get() {
            _number
        }
    }
}

protected open class Request <: CommonPacket {

    protected Request(length: UInt32, number: UInt8) {
        super(length, number)
    }
    
    protected open func toByteArray(): Array<Byte> {
        var appender = ArrayList<Byte>()
        appender.appendAll(uInt32ToLittleEndian(_length).slice(0, 3))
        appender.append(_number)
        return appender.toArray()
    }
    
}
