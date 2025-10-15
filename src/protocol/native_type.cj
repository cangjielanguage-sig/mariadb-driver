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
protected package mysql.protocol

import std.io.*
import std.time.*
import std.math.numeric.*

/*s
* MySQL Binary Protocol Value
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html#sect_protocol_binary_resultset_row_value
*/
protected interface NativeType {

    func writeValue(buffer: ByteBuffer): Unit

    func writeType(buffer: ByteBuffer): Unit

}

extend Bool <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        if(this) {
            [1] |> buffer.write
        } else {
            [0] |> buffer.write
        }
    }

    public func writeType(buffer: ByteBuffer): Unit {
       [ColumnType.Tiny.value(), 0x00] |> buffer.write
    }

}

extend Int8 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
       [ColumnType.Tiny.value(), 0x00] |> buffer.write
    }

}

extend UInt8 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Tiny.value(), 0x80] |> buffer.write
    }

}

extend Int16 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Short.value(), 0x00] |> buffer.write
    }

}

extend UInt16 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Short.value(), 0x80] |> buffer.write
    }

}

extend Int32 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Long.value(), 0x00] |> buffer.write
    }

}

extend UInt32 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Long.value(), 0x80] |> buffer.write
    }

}

extend Int64 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.LongLong.value(), 0x00] |> buffer.write
    }

}

extend UInt64 <: NativeType {


    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.LongLong.value(), 0x80] |> buffer.write
    }

}

extend Float16 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Float.value(), 0x00] |> buffer.write
    }

}

extend Float32 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Float.value(), 0x00] |> buffer.write
    }

}

extend Float64 <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toLittleEndian() |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Double.value(), 0x00] |> buffer.write
    }

}

extend Rune <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toString() |> buffer.writeLengthEncoded
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.VarString.value(), 0x00] |> buffer.write
    }

}

extend Array<Byte> <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        return this |> buffer.writeLengthEncoded
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.LongBlob.value(), 0x00] |> buffer.write
    }

}

extend String <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this |> buffer.writeLengthEncoded
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.VarString.value(), 0x00] |> buffer.write
    }

}

extend DateTime <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        7 |> buffer.write
        UInt16(year).toLittleEndian() |> buffer.write
        UInt8(month.toInteger()) |> buffer.write
        UInt8(dayOfMonth) |> buffer.write
        UInt8(hour) |> buffer.write
        UInt8(minute) |> buffer.write
        UInt8(second) |> buffer.write
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.Timestamp.value(), 0x00] |>  buffer.write
    }

}

extend BigInt <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toString() |> buffer.writeLengthEncoded
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.VarString.value(), 0x00] |>  buffer.write
    }

}

extend Decimal <: NativeType {

    public func writeValue(buffer: ByteBuffer): Unit {
        this.toString() |> buffer.writeLengthEncoded
    }

    public func writeType(buffer: ByteBuffer): Unit {
        [ColumnType.VarString.value(), 0x00] |>  buffer.write
    }

}