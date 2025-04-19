/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.response

import std.io.*
import std.time.*
import std.convert.*
import std.collection.*
import std.math.numeric.*
import encoding.json.*
import mysql.util.*
import mysql.protocol.*

/*
* MySQL Binary Protocol Value
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html#sect_protocol_binary_resultset_row_value
*/
protected interface ToMySqlBinary {

    func toBinary(definition: ColumnDefinition): Array<Byte>

}

protected interface FromMysqlBinary<T> {

    static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?T

}


protected interface MySqlBinary<T> <: ToMySqlBinary & FromMysqlBinary<T> {

}

extend Bool <: MySqlBinary<Bool> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        let value: UInt8 = if(this){ 1 }else { 0 }
        return value.toBinary(definition)
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Bool {
        let value = UInt8.fromBinary(definition, data)
        match (value) {
            case None => None
            case Some(0) => false
            case Some(1) => true
            case Some(_) => throw Exception("")
        }
    }

}

extend Int8 <: MySqlBinary<Int8> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Int8 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return Int8.fromLittleEndian(v)
                    case Short | Year => 
                        return Int8(Int16.fromLittleEndian(v))
                    case Long | Int24 => 
                        return Int8(Int32.fromLittleEndian(v))
                    case LongLong => 
                        return Int8(Int64.fromLittleEndian(v))
                    case Float => 
                        return Int8(Float32.fromLittleEndian(v))
                    case Double => 
                        return Int8(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return Int8.parse(str)
                    case _ => throw IllegalArgumentException("")
                }
        }
    }

}

extend UInt8 <: MySqlBinary<UInt8> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?UInt8 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return UInt8.fromLittleEndian(v)
                    case Short | Year => 
                        return UInt8(UInt16.fromLittleEndian(v))
                    case Long | Int24 => 
                        return UInt8(UInt32.fromLittleEndian(v))
                    case LongLong => 
                        return UInt8(UInt64.fromLittleEndian(v))
                    case Float => 
                        return UInt8(Float32.fromLittleEndian(v))
                    case Double => 
                        return UInt8(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return UInt8.parse(str)
                    case _ => throw UnsupportedException("")
                }
        }
    }

}

extend Int16 <: MySqlBinary<Int16> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Int16 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return Int16(Int8.fromLittleEndian(v))
                    case Short | Year => 
                        return Int16.fromLittleEndian(v)
                    case Long | Int24 => 
                        return Int16(Int32.fromLittleEndian(v))
                    case LongLong => 
                        return Int16(Int64.fromLittleEndian(v))
                    case Float => 
                        return Int16(Float32.fromLittleEndian(v))
                    case Double => 
                        return Int16(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return Int16.parse(str)
                    case _ => throw UnsupportedException("")
                }
        }
    }

}

extend UInt16 <: MySqlBinary<UInt16> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>):? UInt16 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return UInt16(UInt8.fromLittleEndian(v))
                    case Short | Year => 
                        return UInt16.fromLittleEndian(v)
                    case Long | Int24 => 
                        return UInt16(UInt32.fromLittleEndian(v))
                    case LongLong => 
                        return UInt16(UInt64.fromLittleEndian(v))
                    case Float => 
                        return UInt16(Float32.fromLittleEndian(v))
                    case Double => 
                        return UInt16(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return UInt16.parse(str)
                    case _ => throw UnsupportedException("")
                }
        }
    }

}

extend Int32 <: MySqlBinary<Int32> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")      
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Int32 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return Int32(Int8.fromLittleEndian(v))
                    case Short | Year => 
                        return Int32(Int16.fromLittleEndian(v))
                    case Long | Int24 => 
                        return Int32.fromLittleEndian(v)
                    case LongLong => 
                        return Int32(Int64.fromLittleEndian(v))
                    case Float => 
                        return Int32(Float32.fromLittleEndian(v))
                    case Double => 
                        return Int32(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return Int32.parse(str)
                    case _ => throw UnsupportedException("")
                }
        }
    }
}

extend UInt32 <: MySqlBinary<UInt32> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?UInt32 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return UInt32(UInt8.fromLittleEndian(v))
                    case Short | Year => 
                        return UInt32(UInt16.fromLittleEndian(v))
                    case Long | Int24 => 
                        return UInt32.fromLittleEndian(v)
                    case LongLong => 
                        return UInt32(UInt64.fromLittleEndian(v))
                    case Float => 
                        return UInt32(Float32.fromLittleEndian(v))
                    case Double => 
                        return UInt32(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return UInt32.parse(str)
                    case _ => throw UnsupportedException("")
                }
        }
    }
}

extend Int64 <: MySqlBinary<Int64> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Int64 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return Int64(Int8.fromLittleEndian(v))
                    case Short | Year => 
                        return Int64(Int16.fromLittleEndian(v))
                    case Long | Int24 => 
                        return Int64(Int32.fromLittleEndian(v))
                    case LongLong => 
                        return Int64.fromLittleEndian(v)
                    case Float => 
                        return Int64(Float32.fromLittleEndian(v))
                    case Double => 
                        return Int64(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return Int64.parse(str)
                    case _ => throw UnsupportedException("")
                }
        }
    }

}

extend UInt64 <: MySqlBinary<UInt64> {


    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?UInt64 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return UInt64(UInt8.fromLittleEndian(v))
                    case Short | Year => 
                        return UInt64(UInt16.fromLittleEndian(v))
                    case Long | Int24 => 
                        return UInt64(UInt32.fromLittleEndian(v))
                    case LongLong => 
                        return UInt64.fromLittleEndian(v)
                    case Float => 
                        return UInt64(Float32.fromLittleEndian(v))
                    case Double => 
                        return UInt64(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal =>
                        var str = String.fromUtf8(v)
                        return UInt64.parse(str)
                    case _ => throw UnsupportedException("")
                }
        }
    }

}

extend Float16 <: MySqlBinary<Float16> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException()
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Float16 {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Float => 
                        return Float16(Float32.fromLittleEndian(v))
                    case Double => 
                        return Float16(Float64.fromLittleEndian(v))
                    case String | VarString => 
                        return Float16.parse(String.fromUtf8(v))
                    case _ => 
                        throw IllegalArgumentException()
                }   
        }
    }

}

extend Float32 <: MySqlBinary<Float32> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Float32 {
        match(data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Float => 
                        return Float32.fromLittleEndian(v)
                    case Double => 
                        return Float32(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal => 
                        return Float32.parse(String.fromUtf8(v))
                    case _ => 
                        throw IllegalArgumentException()
                }
        }
    }

}

extend Float64 <: MySqlBinary<Float64> {


    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
                throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Float64 {
        match(data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Float => 
                        return Float64(Float32.fromLittleEndian(v))
                    case Double => 
                        return Float64.fromLittleEndian(v)
                    case String | VarString | NewDecimal => 
                        return Float64.parse(String.fromUtf8(v))
                    case _ => 
                        throw IllegalArgumentException("")
                }
        }
    }

}

extend String <: MySqlBinary<String> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
            case String | VarString | NewDecimal | Json | TinyBlob | Blob | MediumBlob | LongBlob =>
                this.toLengthEncoded()
            case Tiny | Short | Year | Int24 | Long | LongLong => 
                try {
                    Int64.parse(this).toBinary(definition)
                }catch (e: IllegalArgumentException) {
                    throw ParameterConvertException("")
                }
            case Float | Double => 
                try {
                    Float64.parse(this).toBinary(definition)
                }catch (e: IllegalArgumentException) {
                    throw ParameterConvertException("")
                }
            case Date => 
                try {
                    DateTime.parse(this, DB_DATE_FORMAT).toBinary(definition)
                }catch(e: TimeParseException) {
                    throw ParameterConvertException("")
                }
            case Time =>
                try {
                   DateTime.parse(DB_TIME_PREFIX + this, DB_DATE_TIME_FORMAT).toBinary(definition)
                }catch (e: TimeParseException) {
                    throw ParameterConvertException("")
                }
            case DateTime | Timestamp =>
                try {
                    DateTime.parse(this, DB_DATE_TIME_FORMAT).toBinary(definition)
                }catch (e: TimeParseException) {
                    throw ParameterConvertException("")
                }
            case _ => 
                throw IllegalArgumentException("")
            }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?String {
        match (data) {
            case None => return None
            case Some(v) => 
                let columnType = definition.columnType
                let unsigned = definition.hasFlag(Unsigned)
                match (columnType) {
                    case Tiny =>
                        if (!unsigned) {
                            return Int8.fromLittleEndian(v).toString()
                        } else {
                            return UInt8.fromLittleEndian(v).toString()
                        }
                    case Short | Year =>
                        if (!unsigned) {
                            return Int16.fromLittleEndian(v).toString()
                        } else {
                            return UInt16.fromLittleEndian(v).toString()
                        }
                    case Long | Int24 =>
                        if (!unsigned) {
                            return Int32.fromLittleEndian(v).toString()
                        } else {
                            return UInt32.fromLittleEndian(v).toString()
                        }
                    case LongLong =>
                        if (!unsigned) {
                            return Int64.fromLittleEndian(v).toString()
                        } else {
                            return UInt64.fromLittleEndian(v).toString()
                        }
                    case Float => 
                        return Float32.fromLittleEndian(v).toString()
                    case Double => 
                        return Float64.fromLittleEndian(v).toString()
                    case VarString | String | Json | Enum | Set | TinyBlob | MediumBlob | LongBlob | Blob | NewDecimal =>
                        return String.fromUtf8(v)
                        // match (charset) {
                        //     case Binary => 
                        //         throw Exception("Unsupported Charset: Binary")
                        //     case Utf8mb3GeneralCi => 
                        //         return String.fromUtf8(data)
                        //     case Latin1SwedishCi => 
                        //         throw Exception("Unsupported Charset: Latin1SwedishCi")
                        // }
                    case Date => 
                        return DateTime.fromBinaryDateTime(v).format(DB_DATE_FORMAT)
                    case DateTime | Timestamp => 
                        return DateTime.fromBinaryDateTime(v).format(DB_DATE_TIME_FORMAT)
                    case Time => 
                        return DateTime.fromBinaryTime(v).format(DB_TIME_FORMAT)
                        //case _ => throw Exception("Unsupport MySQL binary type")
                    }
        }
    }

}

extend DateTime <: MySqlBinary<DateTime> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        match (definition.columnType) {
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
            case _ => throw IllegalArgumentException("")
        }
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?DateTime {
        match(data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Date => 
                        return DateTime.fromBinaryDateTime(v)
                    case DateTime | Timestamp => 
                        return DateTime.fromBinaryDateTime(v)
                    case Time => 
                        return DateTime.fromBinaryTime(v)
                    case _ => 
                        throw IllegalArgumentException("")
                }
        }
    }

}

extend BigInt <: MySqlBinary<BigInt> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        this.toString().toBinary(definition)
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?BigInt {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Tiny => 
                        return BigInt(Int8.fromLittleEndian(v))
                    case Short | Year => 
                        return BigInt(Int16.fromLittleEndian(v))
                    case Int24 | Long => 
                        return BigInt(Int32.fromLittleEndian(v))
                    case LongLong => 
                        return BigInt(Int64.fromLittleEndian(v))
                case String | VarString | Enum | Set | TinyBlob | MediumBlob | LongBlob | Blob | NewDecimal => 
                    return BigInt.parse(String.fromUtf8(v))
                case _ => 
                    throw IllegalArgumentException("")
                }
        }
    }

}

extend Decimal <: MySqlBinary<Decimal> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        this.toString().toBinary(definition)
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?Decimal {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case Float => 
                        return Decimal(Float32.fromLittleEndian(v))
                    case Double => 
                        return Decimal(Float64.fromLittleEndian(v))
                    case String | VarString | NewDecimal | TinyBlob | MediumBlob | LongBlob | Blob => 
                        Decimal.parse(String.fromUtf8(v))
                    case _ => 
                        throw IllegalArgumentException("")
                }
        }
    }

}

extend JsonValue <: MySqlBinary<JsonValue> {

    public func toBinary(definition: ColumnDefinition): Array<Byte> {
        this.toJsonString().toBinary(definition)
    }

    public static func fromBinary(definition: ColumnDefinition, data: ?Array<Byte>): ?JsonValue {
        match (data) {
            case None => return None
            case Some(v) => 
                match (definition.columnType) {
                    case VarString | String | Json | TinyBlob | MediumBlob | LongBlob | Blob =>
                        return JsonValue.fromStr(String.fromUtf8(v))
                    case _ => throw Exception("Unsupport MySQL binary type")
                }
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

    protected static func fromBinaryDateTime(data: Array<Byte>): DateTime {
        let buffer = ByteBuffer(data)
        match (buffer.readFix1Integer()) {
            case 0 => throw IllegalFormatException()
            case 4 =>
                let year = buffer.readFix2Integer()
                let month = buffer.readFix1Integer()
                let day = buffer.readFix1Integer()
                return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day),
                    timeZone: TimeZone.UTC)
            case 7 =>
                let year = buffer.readFix2Integer()
                let month = buffer.readFix1Integer()
                let day = buffer.readFix1Integer()
                let hour = buffer.readFix1Integer()
                let minute = buffer.readFix1Integer()
                let second = buffer.readFix1Integer()
                return DateTime.of(year: Int64(year), month: Int64(month), dayOfMonth: Int64(day), hour: Int64(hour),
                    minute: Int64(minute), second: Int64(second), timeZone: TimeZone.Local)
            case 11 =>
                let year = buffer.readFix2Integer()
                let month = buffer.readFix1Integer()
                let day = buffer.readFix1Integer()
                let hour = buffer.readFix1Integer()
                let minute = buffer.readFix1Integer()
                let second = buffer.readFix1Integer()
                let micorSecond = buffer.readFix4Integer()
                return DateTime.of(year: Int64(year),month: Int64(month),dayOfMonth: Int64(day),hour: Int64(hour),
                    minute: Int64(minute),second: Int64(second),nanosecond: Int64(micorSecond),timeZone: TimeZone.Local)
            case _ => throw InvalidPacketException("")
        }
    }

    protected static func fromBinaryTime(data: Array<Byte>): DateTime {
        let buffer = ByteBuffer(data)
        match (buffer.readFix1Integer()) {
            case 0 => throw IllegalFormatException()
            case 8 =>
                let _ = buffer.readFix1Integer() //negative
                let _ = buffer.readFix4Integer //day
                let hour = buffer.readFix1Integer()
                let minute = buffer.readFix1Integer()
                let second = buffer.readFix1Integer()
                return DateTime.of(year: 1970,month: 1,dayOfMonth: 1, hour: Int64(hour),
                    minute: Int64(minute),second: Int64(second),timeZone: TimeZone.UTC)
            case 12 =>
                let _ = buffer.readFix1Integer() //negative
                let _ = buffer.readFix4Integer() //day
                let hour = buffer.readFix1Integer()
                let minute = buffer.readFix1Integer()
                let second = buffer.readFix1Integer()
                let micorSecond = buffer.readFix4Integer()
                return DateTime.of(year: 1970, month: 1, dayOfMonth: 1, hour: Int64(hour), minute: Int64(minute),
                    second: Int64(second), nanosecond: Int64(micorSecond), timeZone: TimeZone.Local
                )
            case _ => throw InvalidPacketException("")
        }
    }

}