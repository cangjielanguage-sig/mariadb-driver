/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol

import std.io.ByteBuffer
import std.collection.ArrayList
import mysql.util.LittleEndian

/*
* The MySQL Protocol has a set of possible encodings for integers.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_dt_integers.html#sect_protocol_basic_dt_int_fixed
*/
protected interface FixedLengthIntegerReader {
    
    func readFix1Integer(): UInt8

    func readFix2Integer(): UInt16

    func readFix3Integer(): UInt32

    func readFix4Integer(): UInt32

    func readFix6Integer(): UInt64

    func readFix8Integer(): UInt64

    func readFix1IntegerRaw(): Array<Byte>

    func readFix2IntegerRaw(): Array<Byte>

    func readFix3IntegerRaw(): Array<Byte>

    func readFix4IntegerRaw(): Array<Byte>

    func readFix6IntegerRaw(): Array<Byte>

    func readFix8IntegerRaw(): Array<Byte>

}

protected interface LengthEncodeIntegerReader {
    
    func readLengthEncodedInteger(): ?UInt64

    func readLengthEncodedIntegerRaw(): ?Array<Byte>

}

extend ByteBuffer <: FixedLengthIntegerReader {

    public func readFix1Integer(): UInt8 {
        return UInt8.fromLittleEndian(readFix1IntegerRaw())
    }

    public func readFix2Integer(): UInt16 {
        return UInt16.fromLittleEndian(readFix2IntegerRaw())
    }

    public func readFix3Integer(): UInt32 {
        return UInt32.fromLittleEndian(readFix3IntegerRaw())
    }

    public func readFix4Integer(): UInt32 {
        return UInt32.fromLittleEndian(readFix4IntegerRaw())
    }

    public func readFix6Integer(): UInt64 {
        return UInt64.fromLittleEndian(readFix6IntegerRaw())
    }

    public func readFix8Integer(): UInt64 {
        return UInt64.fromLittleEndian(readFix8IntegerRaw())
    }

    public func readFix1IntegerRaw(): Array<Byte> {
        return slice(1)
    }

    public func readFix2IntegerRaw(): Array<Byte> {
        return slice(2)
    }

    public func readFix3IntegerRaw(): Array<Byte> {
        return slice(3)
    }

    public func readFix4IntegerRaw(): Array<Byte> {
        return slice(4)
    }

    public func readFix6IntegerRaw(): Array<Byte> {
        return slice(6)
    }

    public func readFix8IntegerRaw(): Array<Byte> {
        return slice(8)
    }
}

extend ByteBuffer <: LengthEncodeIntegerReader {

    public func readLengthEncodedInteger(): ?UInt64 {
        match (readLengthEncodedIntegerRaw()) {
            case None => return None
            case Some(v) => UInt64.fromLittleEndian(v)
        }
    }

    public func readLengthEncodedIntegerRaw(): ?Array<Byte> {
        let single = slice(1)
        let flag = single[0]
        match (flag) {
            case 0xFB => return None
            case 0xFC =>
                return slice(2)
            case 0xFD =>
                return slice(3)
            case 0xFE =>
                return slice(8)
            case 0xFF => throw InvalidPacketException("This packet is Error packet")
            case _ => return single
        }
    }

}

extend UInt64 <: ToLengthEncoded {

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