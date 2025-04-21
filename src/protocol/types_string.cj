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

import std.io.ByteBuffer
import std.io.SeekPosition
import std.collection.ArrayList
import mysql.util.LittleEndian

/*
* Strings are sequences of bytes and appear in a few forms in the protocol.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_dt_strings.html
*/
public interface MySqlStringReader {

    func readFixedArray(size: Int64): Array<Byte>

    func readFixedString(size: Int64): String
    
    func readNullTerminatedString(): String

    func readNullTerminatedStringRaw(): Array<Byte>

    func readLengthEncodedString(): ?String

    func readLengthEncodedStringRaw(): ?Array<Byte>

}

protected interface ToLengthEncoded {

    func toLengthEncoded(): Array<Byte>

}

protected interface ToNullTerminated {

    func toNullTerminated(): Array<Byte>

}

extend ByteBuffer <: MySqlStringReader {

    public func readFixedArray(length: Int64): Array<Byte> {
        if (length == 0) {
            return []
        }
        let data = Array<Byte>(length, repeat: 0)
        if(read(data) != length) {
            throw InvalidPacketException("read fixed array failed")
        }
        // let data = this.bytes().slice(0, length)
        // this.seek(Current(length))
        return data
    }

    public func readFixedString(size: Int64): String {
        return String.fromUtf8(readFixedArray(size))
    }

    public func readNullTerminatedString(): String {
        return String.fromUtf8(readNullTerminatedStringRaw())
    }

    public func readNullTerminatedStringRaw(): Array<Byte> {
        let offset = this.bytes().indexOf(0) ?? throw InvalidPacketException("read a null terminated string failed")
        let data = readFixedArray(offset)
        this.readByte()//skip \0
        return data
    }

    public func readLengthEncodedString(): ?String {
        match (readLengthEncodedStringRaw()) {
            case None => return None
            case Some(v) => return String.fromUtf8(v)
        }
    }

    public func readLengthEncodedStringRaw(): ?Array<Byte> {
        match (readLengthEncodedInteger()) {
            case None => return None
            case Some(length) => return readFixedArray(Int64(length))
        }
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
        let buf = ArrayList<Byte>(this.size + 9)
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