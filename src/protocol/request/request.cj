/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol.request

import std.collection.ArrayList
import mysql.protocol.LittleEndian

protected open class Request {

    private static let Header: Array<Byte> = [0x00, 0x00, 0x00]

    internal let buf: ArrayList<Byte> = ArrayList<Byte>()

    protected var number: UInt8

    protected init(number: UInt8) {
        this.number = number
    }
    
    protected func clear(): Unit {
        buf.clear()
    }
    
    protected open func pack(): Unit {
        buf.appendAll(Header)
        buf.append(number)
    }

    protected func setHeader(): Unit {
        try {
            let header = UInt32(buf.size - 4).toLittleEndian()
            buf.set(0, header[0])
            buf.set(1, header[1])
            buf.set(2, header[2])
        }catch (e: OverflowException) {
            throw Exception("current package size is to large")
        }
    }

    protected func toByteArray(): Array<Byte> {
        setHeader()
        return buf.toArray()
    }
    
}