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
protected package mysql.protocol.response

import std.time.*
import std.convert.*
import std.collection.*
import std.math.numeric.*
import mysql.util.*
import mysql.protocol.*

/*
* MySQL Binary Protocol Value
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html#sect_protocol_binary_resultset_row_value
*/
protected interface ToMySqlBinary {

    func toBinary(definition: ColumnDefinition): Array<Byte>

}

extend Bool <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let value: UInt8 = if(this){ 1 }else { 0 }
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                value.toLittleEndian()
            case Short =>
                Int16(value).toLittleEndian()
            case Int24 | Long | Year => 
                Int32(value).toLittleEndian()
            case LongLong =>
                Int64(value).toLittleEndian()
            case Float => 
                Float32(value).toLittleEndian()
            case Double => 
                Float64(value).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Boolean types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend Int8 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                this.toLittleEndian()
            case Short =>
                Int16(this).toLittleEndian()
            case Int24 | Long | Year => 
                Int32(this).toLittleEndian()
            case LongLong =>
                Int64(this).toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Int8 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend UInt8 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => this.toLittleEndian()
            case Short => 
                UInt16(this).toLittleEndian()
            case Long | Int24 | Year => 
                UInt32(this).toLittleEndian()
            case LongLong => 
                UInt64(this).toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie UInt8 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend Int16 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                Int8(this).toLittleEndian()
            case Short => 
                Int16(this).toLittleEndian()
            case Int24 | Long | Year => 
                Int32(this).toLittleEndian()
            case LongLong => 
                Int64(this).toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Int16 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend UInt16 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                UInt8(this).toLittleEndian() // possible overflow
            case Short => 
                this.toLittleEndian()
            case Long | Int24 | Year => 
                UInt32(this).toLittleEndian()
            case LongLong => 
                UInt64(this).toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toBinary(definition)
            case _ => 
                throw IllegalArgumentException("Cangjie UInt16 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend Int32 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                Int8(this).toLittleEndian()
            case Short => 
                Int16(this).toLittleEndian()
            case Int24 | Long | Year => 
                Int32(this).toLittleEndian()
            case LongLong => 
                Int64(this).toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Int32 types cannot be converted to MySql ${columnType} types")      
        }
    }

}

extend UInt32 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                UInt8(this).toLittleEndian() // possible overflow
            case Short =>
                UInt16(this).toLittleEndian() // possible overflow
            case Int24 | Long | Year => 
                this.toLittleEndian() 
            case LongLong => 
                UInt64(this).toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie UInt32 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend Int64 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                Int8(this).toLittleEndian()
            case Short => 
                Int16(this).toLittleEndian()
            case Int24 | Long | Year => 
                Int32(this).toLittleEndian()
            case LongLong => 
                Int64(this).toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Int64 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend UInt64 <: ToMySqlBinary {


    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Tiny => 
                UInt8(this).toLittleEndian() // possible overflow
            case Short => 
                UInt16(this).toLittleEndian() // possible overflow
            case Int24 | Long | Year => 
                UInt32(this).toLittleEndian() // possible overflow
            case LongLong => 
                this.toLittleEndian()
            case Float => 
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie UInt64 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend Float16 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Float =>
                Float32(this).toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case Tiny => 
                Int8(this).toLittleEndian()
            case Short =>
                Int16(this).toLittleEndian()
            case Int24 | Long  => 
                Int32(this).toLittleEndian()
            case LongLong => 
                Int64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Float16 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend Float32 <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Float =>
                this.toLittleEndian()
            case Double => 
                Float64(this).toLittleEndian()
            case Tiny => 
                Int8(this).toLittleEndian()
            case Short =>
                Int16(this).toLittleEndian()
            case Int24 | Long  => 
                Int32(this).toLittleEndian()
            case LongLong => 
                Int64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Float32 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend Float64 <: ToMySqlBinary {


    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Float =>
                Float32(this).toLittleEndian()
            case Double => 
                this.toLittleEndian()
            case Tiny => 
                Int8(this).toLittleEndian()
            case Short =>
                Int16(this).toLittleEndian()
            case Int24 | Long  => 
                Int32(this).toLittleEndian()
            case LongLong => 
                Int64(this).toLittleEndian()
            case String | VarString | NewDecimal | TinyBlob | Blob | MediumBlob | LongBlob => 
                this.toString().toLengthEncoded()
            case _ => 
                throw IllegalArgumentException("Cangjie Float64 types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend String <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case String | VarString | NewDecimal | Json | TinyBlob | Blob | MediumBlob | LongBlob =>
                this.toLengthEncoded()
            case Tiny | Short | Year | Int24 | Long | LongLong => 
                    Int64.parse(this).toBinary(definition)
            case Float | Double => 
                    Float64.parse(this).toBinary(definition)
            case Date => 
                    DateTime.parse(this, DB_DATE_FORMAT).toBinary(definition)
            case Time =>
                    DateTime.parse(DB_TIME_PREFIX + this, DB_DATE_TIME_FORMAT).toBinary(definition)
            case DateTime | Timestamp =>
                    DateTime.parse(this, DB_DATE_TIME_FORMAT).toBinary(definition)
            case _ => 
                throw IllegalArgumentException("Cangjie String types cannot be converted to MySql ${columnType} types")
            }
    }

}

extend DateTime <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        match (columnType) {
            case Year =>
                Int32(this.year).toBinary(definition)
            case Date => 
                this.toBinaryDate()
            case Time =>
                this.toBinaryTime()
            case Timestamp | DateTime => 
                this.toBinaryDateTime()
            case String | VarString | Blob => 
                this.format(DB_DATE_TIME_FORMAT).toBinary(definition)
            case _ => throw IllegalArgumentException("Cangjie DateTime types cannot be converted to MySql ${columnType} types")
        }
    }

}

extend BigInt <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        let value = this.toString()
        match (columnType) {
            case String | VarString | NewDecimal | Json | TinyBlob | Blob | MediumBlob | LongBlob =>
                value.toLengthEncoded()
            case Tiny | Short | Year | Int24 | Long | LongLong => 
                Int64.parse(value).toBinary(definition)
            case Float | Double => 
                Float64.parse(value).toBinary(definition)
            case _ => 
                throw IllegalArgumentException("Cangjie BigInt types cannot be converted to MySql ${columnType} types")
            }
    }

}

extend Decimal <: ToMySqlBinary {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let columnType = definition.columnType
        let value = this.toString()
        match (columnType) {
            case String | VarString | NewDecimal | Json | TinyBlob | Blob | MediumBlob | LongBlob =>
                value.toLengthEncoded()
            case Tiny | Short | Year | Int24 | Long | LongLong => 
                Int64.parse(value).toBinary(definition)
            case Float | Double => 
                Float64.parse(value).toBinary(definition)
            case _ => 
                throw IllegalArgumentException("Cangjie Decimal types cannot be converted to MySql ${columnType} types")
            }
    }

}

extend DateTime {
    
    protected func toBinaryDate(): Array<Byte> {
        let buf = ArrayList<Byte>(5)
        buf.add(4)
        buf.add(all: UInt16(year).toLittleEndian())
        buf.add(UInt8(month.toInteger()))
        buf.add(UInt8(dayOfMonth))
        return buf.toArray()
    }

    @OverflowWrapping
    protected func toBinaryTime(): Array<Byte> {
        let buf = ArrayList<Byte>(9)
        buf.add(8)
        buf.add(0x00)
        buf.add(all: [0x00, 0x00, 0x00, 0x00])
        buf.add(UInt8(hour))
        buf.add(UInt8(minute))
        buf.add(UInt8(second))
        return buf.toArray()
    }

    @OverflowWrapping
    protected func toBinaryDateTime(): Array<Byte> {
        var buf = ArrayList<Byte>(8)
        buf.add(7)
        buf.add(all: UInt16(year).toLittleEndian())
        buf.add(UInt8(month.toInteger()))
        buf.add(UInt8(dayOfMonth))
        buf.add(UInt8(hour))
        buf.add(UInt8(minute))
        buf.add(UInt8(second))
        return buf.toArray()
    }

}