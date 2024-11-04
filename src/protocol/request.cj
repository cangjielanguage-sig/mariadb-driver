/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.collection.ArrayList

protected open class Request <: CommonPacket {

    protected let buf: ArrayList<Byte> = ArrayList<Byte>()

    protected init(length: UInt32, number: UInt8) {
        super(length, number)
    }

    protected func reset(size: UInt32): Unit {
        var array: Array<Byte> = size.toLittleEndian()
        buf.set(0, array[0])
        buf.set(1, array[1])
        buf.set(2, array[2])
    }
    
    protected func clear(): Unit {
        buf.clear()
    }
    
    protected open func pack(): Unit {
        buf.appendAll(_length.toLittleEndian().slice(0, 3))
        buf.append(_number)
    }

    protected open func toByteArray(): Array<Byte> {
        return buf.toArray()
    }
    
}