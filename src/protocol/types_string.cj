/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol

import std.io.ByteBuffer
import std.collection.ArrayList
import mysql.util.LittleEndian

/*
* Strings are sequences of bytes and appear in a few forms in the protocol.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_dt_strings.html
*/
public interface FixedLengthStringReader {

    func readFixedString(size: Int64): String

}

public interface NullTerminatedStringReader {

    func readNullTerminatedString(): String

    func readNullTerminatedStringRaw(): Array<Byte>

}

public interface LengthEncodedStringReader {

    func readLengthEncodedString(): ?String

    func readLengthEncodedStringRaw(): ?Array<Byte>

}

protected interface ToLengthEncoded {

    func toLengthEncoded(): Array<Byte>

}

protected interface ToNullTerminated {

    func toNullTerminated(): Array<Byte>

}

extend ByteBuffer <: FixedLengthStringReader {

    public func readFixedString(size: Int64): String {
        let temp = Array<Byte>(size, repeat: 0)
        if(read(temp) != size) {
            throw InvalidPacketException()
        }
        return String.fromUtf8(temp)
    }

}

extend ByteBuffer <: NullTerminatedStringReader {

    public func readNullTerminatedString(): String {
        return String.fromUtf8(readNullTerminatedStringRaw())
    }

    public func readNullTerminatedStringRaw(): Array<Byte> {
        let buf = ArrayList<Byte>()
        while (true) {
            let b = match (readByte()) {
                case None => throw InvalidPacketException("read a null terminated string failed")
                case Some(v) => v
            }
            if(b == 0) {
                break
            }
            buf.add(b)
        }
        return buf.toArray()
    }

}

extend ByteBuffer <: LengthEncodedStringReader {

    public func readLengthEncodedString(): ?String {
        match (readLengthEncodedStringRaw()) {
            case None => return None
            case Some(v) => return String.fromUtf8(v)
        }
    }

    public func readLengthEncodedStringRaw(): ?Array<Byte> {
        match (readLengthEncodedInteger()) {
            case None => return None
            case Some(length) => return readStringRaw(length)
        }
    }

    private func readStringRaw(length: UInt64): Array<Byte> {
        if (length == 0) {
            return []
        }
        let data = Array<Byte>(Int64(length), repeat: 0)
        read(data)
        return data
    }

}

extend String <: ToLengthEncoded & ToNullTerminated {

    public func toLengthEncoded(): Array<Byte> {
        return this.toArray().toLengthEncoded()
    }

    public func toNullTerminated(): Array<Byte> {
        return this.toArray().toNullTerminated()
    }
    
}

extend Array<Byte> <: ToLengthEncoded & ToNullTerminated {

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

}