/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol

import std.collection.ArrayList

protected interface ToBool {

    func toBool(): Bool

}


extend String <: ToLengthEncoded & ToNullTerminated & ToBool {

    public func toLengthEncoded(): Array<Byte> {
        return this.toArray().toLengthEncoded()
    }

    public func toNullTerminated(): Array<Byte> {
        return this.toArray().toNullTerminated()
    }

    public func toBool(): Bool {
        match (this) {
            case "1" => return true
            case "0" => return false
            case _ => throw IllegalArgumentException("parse string to bool faild")
        }
    }

}

extend UInt <: ToLengthEncoded {

    public func toLengthEncoded(): Array<Byte> {
        let buf = ArrayList<Byte>()
        if (this < 0xFB) {
            buf.add(UInt8(this))
        } else if (this < UInt64(1 << 16)) {
            buf.add(0xFC)
            buf.add(all: UInt16(this).toLittleEndian())
        } else if (this < UInt64(1 << 24)) {
            buf.add(0xFD)
            buf.add(all: UInt32(this).toLittleEndian().slice(0, 3))
        } else {
            buf.add(0xFE)
            buf.add(all: this.toLittleEndian())
        }
        return buf.toArray()
    }

}
