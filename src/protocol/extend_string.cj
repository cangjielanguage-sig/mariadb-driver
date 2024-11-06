/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.collection.ArrayList

protected interface ToLengthEncoded {

    func toLengthEncoded(): Array<Byte>

}

protected interface ToNullTerminated {

    func toNullTerminated(): Array<Byte>

}

extend String <: ToLengthEncoded & ToNullTerminated {

    public func toLengthEncoded(): Array<Byte> {
        let buf = ArrayList<Byte>()
        if (this.size <= 0xFA) {
            buf.append(UInt8(this.size))
            buf.appendAll(this.toArray())
        } else if (this.size <= (1 << 16)) {
            buf.append(0xFC)
            buf.appendAll(UInt16(this.size).toLittleEndian())
            buf.appendAll(this.toArray())
        } else if (this.size <= (1 << 24)) {
            buf.append(0xFD)
            buf.appendAll(UInt32(this.size).toLittleEndian().slice(0, 3))
            buf.appendAll(this.toArray())
        } else {
            buf.append(0xFE)
            buf.appendAll(UInt64(this.size).toLittleEndian())
            buf.appendAll(this.toArray())
        }
        buf.toArray()
    }

    public func toNullTerminated(): Array<Byte> {
        let buf = ArrayList<Byte>(this.size + 1)
        buf.appendAll(this.toArray())
        buf.append(0)
        return buf.toArray()
    }

}

extend UInt <: ToLengthEncoded {

    public func toLengthEncoded(): Array<Byte> {
        let buf = ArrayList<Byte>()
        if (this < 0xFB) {
            buf.append(UInt8(this))
        } else if (this < UInt64(1 << 16)) {
            buf.append(0xFC)
            buf.appendAll(UInt16(this).toLittleEndian())
        } else if (this < UInt64(1 << 24)) {
            buf.append(0xFD)
            buf.appendAll(UInt32(this).toLittleEndian().slice(0, 3))
        } else {
            buf.append(0xFE)
            buf.appendAll(this.toLittleEndian())
        }
        return buf.toArray()
    }

}
