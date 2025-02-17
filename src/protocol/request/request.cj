/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.request

import std.collection.*
import mysql.protocol.*

protected open class Request {

    private static let Header: Array<Byte> = Array<Byte>(3, repeat: 0)

    private let buf: ArrayList<Byte> = ArrayList<Byte>()

    protected var number: UInt8

    protected init(number: UInt8) {
        this.number = number
    }

    protected func pack(data: Array<Byte>): Unit {
        buf.add(all: data)
    }
    
    protected open func pack(): Unit {
        buf.add(all: Header)
        buf.add(number)
    }

    protected func clear(): Unit {
        buf.clear()
    }
    
    protected func toByteArray(): Array<Byte> {
        pack()
        setHeader()
        return buf.toArray()
    }
    
    private func setHeader(): Unit {
        try {
            let header = UInt32(buf.size - 4).toLittleEndian()
            buf[0] = header[0]
            buf[1] = header[1]
            buf[2] = header[2]
        }catch (e: OverflowException) {
            throw Exception("current package size is to large")
        }
    }
}