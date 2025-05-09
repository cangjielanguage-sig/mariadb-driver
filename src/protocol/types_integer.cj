/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mysql.protocol

import std.io.*
import std.collection.*

/*
* The MySQL Protocol has a set of possible encodings for integers.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_dt_integers.html#sect_protocol_basic_dt_int_fixed
*/
protected interface MySqlIntegerReader {
    
    func readFix1Integer(): UInt8

    func readFix2Integer(): UInt16

    func readFix3Integer(): UInt32

    func readFix4Integer(): UInt32

    func readFix6Integer(): UInt64

    func readFix8Integer(): UInt64

    func readLengthEncodedInteger(): ?UInt64

    func readLengthEncodedIntegerRaw(): ?Array<Byte>

}

extend ByteBuffer <: MySqlIntegerReader {

    public func readFix1Integer(): UInt8 {
        return UInt8.fromLittleEndian(readFixedArray(1))
    }

    public func readFix2Integer(): UInt16 {
        return UInt16.fromLittleEndian(readFixedArray(2))
    }

    public func readFix3Integer(): UInt32 {
        return UInt32.fromLittleEndian(readFixedArray(3))
    }

    public func readFix4Integer(): UInt32 {
        return UInt32.fromLittleEndian(readFixedArray(4))
    }

    public func readFix6Integer(): UInt64 {
        return UInt64.fromLittleEndian(readFixedArray(6))
    }

    public func readFix8Integer(): UInt64 {
        return UInt64.fromLittleEndian(readFixedArray(8))
    }

    public func readLengthEncodedInteger(): ?UInt64 {
        match (readLengthEncodedIntegerRaw()) {
            case None => return None
            case Some(v) => UInt64.fromLittleEndian(v)
        }
    }

    public func readLengthEncodedIntegerRaw(): ?Array<Byte> {
        let flag = readFix1Integer()
        match (flag) {
            case 0xFB => return None
            case 0xFC =>
                return readFixedArray(2)
            case 0xFD =>
                return readFixedArray(3)
            case 0xFE =>
                return readFixedArray(8)
            case 0xFF => throw InvalidPacketException("This packet is Error packet")
            case _ => return [flag]
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