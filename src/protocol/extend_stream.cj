/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.io.ByteBuffer

protected interface ReadLengthEncoded {
    
    func readLengthEncodedString(): ?String

    func readLengthEncodedStringRaw(): ?Array<Byte>

    func readLengthEncodedInteger(): ?UInt

    func readLengthEncodedIntegerRaw(): ?Array<Byte>
}

extend ByteBuffer <: ReadLengthEncoded {

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

    public func readLengthEncodedInteger(): ?UInt {
        match (readLengthEncodedIntegerRaw()) {
            case None => return None
            case Some(v) => UInt64.fromLittleEndian(v)
        }
    }

    public func readLengthEncodedIntegerRaw(): ?Array<Byte> {
        let single = Array<Byte>(1, repeat: 0)
        if (read(single) == 0) {
            throw IllegalArgumentException("read a length encoded integer failed")
        }
        let flag = single[0]
        match (flag) {
            case 0xFB => return None
            case 0xFC =>
                let buffer = Array<Byte>(2, repeat: 0)
                read(buffer)
                return buffer
            case 0xFD =>
                let buffer = Array<Byte>(3, repeat: 0)
                read(buffer)
                return buffer
            case 0xFE =>
                let buffer = Array<Byte>(8, repeat: 0)
                read(buffer)
                return buffer
            case 0xFF => throw InvalidPacketException("This packet is Error packet")
            case _ => return single
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
