/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.log.*
import std.collection.*
import std.console.*
import std.io.*

/*
* MySQL Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_packets.html
*/
protected open class CommonPacket {

    internal static const LENGTH_SIZE: Int = 3

    internal static const NUMBER_SIZE: Int = 1

    internal static const HEADER_SIZE: Int = LENGTH_SIZE + NUMBER_SIZE;

    internal var _length: UInt32

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
    protected init(length: UInt32, number: UInt8) {
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

    protected let buf: ArrayList<Byte> = ArrayList<Byte>()

    protected init(length: UInt32, number: UInt8) {
        super(length, number)
    }

    protected func reset(size: UInt32): Unit {
        var array: Array<Byte> = uInt32ToLittleEndian(size)
        buf.set(0, array[0])
        buf.set(1, array[1])
        buf.set(2, array[2])
    }
    
    protected func clear(): Unit {
        buf.clear()
    }
    
    protected open func pack(): Unit {
        buf.appendAll(uInt32ToLittleEndian(_length).slice(0, 3))
        buf.append(_number)
    }

    protected open func toByteArray(): Array<Byte> {
        return buf.toArray()
    }
    
}
