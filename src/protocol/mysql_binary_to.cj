/*
 * Copyright (c) 2024-2025 Yesokim
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

import std.time.*
import std.math.numeric.*
import mysql.util.*

/*s
* MySQL Binary Protocol Value
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html#sect_protocol_binary_resultset_row_value
*/
protected interface ToMySqlBinary {

    func toBinary(): Array<Byte>

    func typeFlag(): Array<Byte>

}

extend Bool <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        if(this) {
            return [1]
        } else {
            [0]
        }
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Tiny.value(), 0x00]
    }

}

extend Int8 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Tiny.value(), 0x00]
    }

}

extend UInt8 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Tiny.value(), 0x80]
    }

}

extend Int16 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Short.value(), 0x00]
    }

}

extend UInt16 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Short.value(), 0x80]
    }

}

extend Int32 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Long.value(), 0x00]
    }

}

extend UInt32 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Long.value(), 0x80]
    }

}

extend Int64 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.LongLong.value(), 0x00]
    }

}

extend UInt64 <: ToMySqlBinary {


    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.LongLong.value(), 0x80]
    }

}

extend Float16 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Float.value(), 0x00]
    }

}

extend Float32 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Float.value(), 0x00]
    }

}

extend Float64 <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLittleEndian()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Double.value(), 0x00]
    }

}

extend Rune <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toString().toLengthEncoded()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.VarString.value(), 0x00]
    }

}

extend Array<Byte> <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLengthEncoded()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.LongBlob.value(), 0x00]
    }

}

extend String <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toLengthEncoded()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.VarString.value(), 0x00]
    }

}

extend DateTime <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        var index = 0
        var buf = Array<Byte>(8, repeat: 0)
        buf[index] = 7
        index ++
        UInt16(year).toLittleEndian().copyTo(buf, 0, index, 2)
        index += 2
        buf[index] = UInt8(month.toInteger())
        index ++
        buf[index] = UInt8(dayOfMonth)
        index ++
        buf[index] = UInt8(hour)
        index ++
        buf[index] = UInt8(minute)
        index ++
        buf[index] = UInt8(second)
        return buf.toArray()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.Timestamp.value(), 0x00]
    }

}

extend BigInt <: ToMySqlBinary {

    public func toBinary(): Array<Byte> {
        return this.toString().toLengthEncoded()
    }

    public func typeFlag(): Array<Byte> {
        return [ColumnType.VarString.value(), 0x00]
    }

}

extend Decimal <: ToMySqlBinary {

    public func typeFlag(): Array<Byte> {
        return [ColumnType.VarString.value(), 0x00]
    }

    public func toBinary(): Array<Byte> {
        return this.toString().toLengthEncoded()
    }

}