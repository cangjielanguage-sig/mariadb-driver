/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
protected package mariadb.protocol

import std.io.*

extend ByteBuffer {

    public func readInt1(): UInt8 {
        return UInt8.fromLittleEndian(readArray(1))
    }

    public func readInt2(): UInt16 {
        return UInt16.fromLittleEndian(readArray(2))
    }

    // public func readInt3(): UInt32 {
    //     return UInt32.fromLittleEndian(readArray(3))
    // }

    public func readInt4(): UInt32 {
        return UInt32.fromLittleEndian(readArray(4))
    }

    // public func readInt6(): UInt64 {
    //     return UInt64.fromLittleEndian(readArray(6))
    // }

    // public func readInt8(): UInt64 {
    //     return UInt64.fromLittleEndian(readArray(8))
    // }

    public func readLengthEncodedInteger(): ?UInt64 {
        match (readLengthEncodedIntegerRaw()) {
            case None => return None
            case Some(v) => UInt64.fromLittleEndian(v)
        }
    }

    public func readLengthEncodedIntegerRaw(): ?Array<Byte> {
        let flag = readInt1()
        match (flag) {
            case 0xFB => return None
            case 0xFC =>
                return readArray(2)
            case 0xFD =>
                return readArray(3)
            case 0xFE =>
                return readArray(8)
            case 0xFF => throw InvalidPacketException("This packet is Error packet")
            case _ => return [flag]
        }
    }

}

extend ByteBuffer {

    protected func writeInt1(value: UInt8): Unit {
        write(value)
    }

    protected func writeInt2(value: UInt16): Unit {
        write(value.toLittleEndian())
    }

    protected func writeInt3(value: UInt32): Unit {
        write(value.toLittleEndian().slice(0, 3))
    }

    protected func writeInt4(value: UInt32): Unit {
        write(value.toLittleEndian())
    }

    // protected func writeInt6(value: UInt64): Unit {
    //     write(value.toLittleEndian().slice(0, 6))
    // }

    protected func writeInt8(value: UInt64): Unit {
        write(value.toLittleEndian())
    }

    protected func writeLengthEncoded(value: UInt64): Unit {
        if (value < 0xFB) {
            writeInt1(UInt8(value))
        } else if (value < UInt64(1 << 16)) {
            writeInt1(0xFC)
            writeInt2(UInt16(value))
        } else if (value < UInt64(1 << 24)) {
            writeInt1(0xFD)
            writeInt3(UInt32(value))
        } else {
            writeInt1(0xFE)
            writeInt8(value)
        }
    }

}