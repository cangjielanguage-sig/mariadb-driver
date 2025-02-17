/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol

import std.collection.*
import encoding.hex.*

protected interface ToLengthEncoded {

    func toLengthEncoded(): Array<Byte>

}

protected interface ToNullTerminated {

    func toNullTerminated(): Array<Byte>

}

protected interface ToHexString {
    
    func toHexString(): String

    func toHexStringWithPrefix(): String

}

extend Array<Byte> <: ToLengthEncoded & ToNullTerminated & ToHexString {


    public func toLengthEncoded(): Array<Byte> {
        let buf = ArrayList<Byte>()
        if (this.size <= 0xFA) {
            buf.add(UInt8(this.size))
            buf.add(all: this)
        } else if (this.size <= (1 << 16)) {
            buf.add(0xFC)
            buf.add(all: UInt16(this.size).toLittleEndian())
            buf.add(all: this)
        } else if (this.size <= (1 << 24)) {
            buf.add(0xFD)
            buf.add(all: UInt32(this.size).toLittleEndian().slice(0, 3))
            buf.add(all: this)
        } else {
            buf.add(0xFE)
            buf.add(all: UInt64(this.size).toLittleEndian())
            buf.add(all: this)
        }
        buf.toArray()
    }

    public func toNullTerminated(): Array<Byte> {
        let buf = ArrayList<Byte>(this.size + 1)
        buf.add(all: this)
        buf.add(0)
        return buf.toArray()
    }

    public func toHexString(): String {
        return toHexString(this)
    }

    public func toHexStringWithPrefix(): String {
        if(this.size == 0) {
            return "''"
        }
        return "0x${toHexString()}"
    }

}