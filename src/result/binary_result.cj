/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.result

import std.time.DateTime
import std.time.TimeParseException
import std.io.ByteBuffer
import std.io.InputStream
import std.math.numeric.BigInt
import std.math.numeric.Decimal
import std.convert.Parsable
import std.collection.HashMap
import encoding.json.JsonValue
import mysqlclient4cj.protocol.*
import mysqlclient4cj.protocol.response.*


protected class BinaryResultSet <: ResultSet {
    
    private let columns: Array<ColumnDefinition>

    private let rows: Array<Array<?Array<Byte>>>

    private let indexMap: HashMap<String, Int64>

    private var currentRow: Int64

    protected BinaryResultSet(columns: Array<ColumnDefinition>, rows: Array<Array<?Array<Byte>>>) {
        this.columns = columns
        this.rows = rows
        this.currentRow = 0
        indexMap = HashMap<String, Int64>()
        for (i in 0..columns.size) {
            indexMap.put(columns[i].name, i + 1)
        }
    }

    public prop columnDefinitions: Array<ColumnDefinition> {
        get() {
            columns
        }
    }

    public func next(): Bool {
        if (currentRow >= rows.size) {
            return false
        } else {
            currentRow++
            return true
        }
    }

    public override func getIndexByName(name: String): Int64 {
        return indexMap.get(name).getOrThrow()
    }

    public override func getBool(index: Int64): ?Bool {
        match (getString(index)) {
            case None => return None
            case Some(v) => return v.toBool()
        }
    }

    @OverflowWrapping
    public override func getInt8(index: Int64): ?Int8 {
        match (getUInt8(index)) {
            case None => None
            case Some(v) => Int8(v)
        }
    }

    public override func getUInt8(index: Int64): ?UInt8 {
        match (getUInt64(index)) {
            case None => None
            case Some(v) => UInt8(v)
        }
    }

    @OverflowWrapping
    public override func getInt16(index: Int64): ?Int16 {
        match (getUInt16(index)) {
            case None => None
            case Some(v) => Int16(v)
        }
    }

    public override func getUInt16(index: Int64): ?UInt16 {
        match (getUInt64(index)) {
            case None => None
            case Some(v) => UInt16(v)
        }
    }

    @OverflowWrapping
    public override func getInt32(index: Int64): ?Int32 {
        match (getUInt32(index)) {
            case None => None
            case Some(v) => Int32(v)
        }
    }

    public override func getUInt32(index: Int64): ?UInt32 {
        match (getUInt64(index)) {
            case None => None
            case Some(v) => UInt32(v)
        }
    }

    @OverflowWrapping
    public override func getInt64(index: Int64): ?Int64 {
        match (getUInt64(index)) {
            case None => None
            case Some(v) => Int64(v)
        }
    }

    public override func getUInt64(index: Int64): ?UInt64 {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                match (columnType) {
                    case Tiny => 
                        return UInt64(v[0])
                    case Short | Year => 
                        return UInt64(UInt16.fromLittleEndian(v))
                    case Long | Int24 => 
                        return UInt64(UInt32.fromLittleEndian(v))
                    case LongLong => 
                        return UInt64.fromLittleEndian(v)
                    case Float => 
                        return UInt64(getFloat32(index).getOrThrow())
                    case Double => 
                        return UInt64(getFloat64(index).getOrThrow())
                    case String | VarString | NewDecimal =>
                        var str = getString(index).getOrThrow()
                        try {
                            return UInt64.parse(str)
                        } catch (e: IllegalArgumentException) {
                            throw ValueConvertException("Parse to Integer failed: column name is '${getFieldName(index)}', raw value is ${str}")
                        }
                    case _ => throw ValueConvertException("Unsupported conversion from ${columnType} to Integer")
                }
        }
    }


    public override func getFloat16(index: Int64): ?Float16 {
        match (getFloat32(index)) {
            case None => None
            case Some(v) => return Float16(v)
        }
    }

    public override func getFloat32(index: Int64): ?Float32 {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                match (columnType) {
                    case Float => 
                        return Float32.fromLittleEndian(v)
                    case Double => 
                        return Float32(getFloat64(index).getOrThrow())
                    case String | VarString => 
                        return Float32.parse(getString(index).getOrThrow())
                    case _ => 
                        throw ValueConvertException("Unsupported conversion from ${columnType} to Float32")
                }   
        }
    }

    public override func getFloat64(index: Int64): ?Float64 {
        match(getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                match (columnType) {
                    case Float => 
                        return Float64(getFloat32(index).getOrThrow())
                    case Double => 
                        return Float64.fromLittleEndian(v)
                    case String | VarString | NewDecimal => 
                        return Float64.parse(getString(index).getOrThrow())
                    case _ => 
                        throw ValueConvertException("Unsupported conversion from ${columnType} to Float64")
                }
        }
    }

    public override func getBigInt(index: Int64): ?BigInt {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                match (columnType) {
                    case Tiny => 
                        return BigInt(getInt8(index).getOrThrow())
                    case Short | Year => 
                        return BigInt(getInt16(index).getOrThrow())
                    case Int24 | Long => 
                        return BigInt(getInt32(index).getOrThrow())
                    case LongLong => 
                        return BigInt(getInt64(index).getOrThrow())
                case String | VarString => 
                    return BigInt(getString(index).getOrThrow())
                case _ => 
                    throw ValueConvertException("Unsupported conversion from ${columnType} to BigInt")
                }
        }
    }

    public override func getDecimal(index: Int64): ?Decimal {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                match (columnType) {
                    case Float => 
                        return Decimal(getFloat32(index).getOrThrow())
                    case Double => 
                        return Decimal(getFloat64(index).getOrThrow())
                    case String | VarString | NewDecimal => 
                        Decimal(getString(index).getOrThrow())
                    case _ => 
                        throw ValueConvertException("Unsupported conversion from ${columnType} to Integer")
        }
        }

    }

    public override func getDate(index: Int64): ?DateTime {
        return getTimestamp(index)
    }

    public override func getTime(index: Int64): ?DateTime {
        return getTimestamp(index)
    }

    public func getDateTime(index: Int64): ?DateTime {
        return getTimestamp(index)
    }

    public func getTimestamp(index: Int64): ?DateTime {
        match(getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                match (columnType) {
                    case Date => 
                        return DateTime.fromBinaryDateTime(v)
                    case DateTime | Timestamp => 
                        return DateTime.fromBinaryDateTime(v)
                    case Time => 
                        return DateTime.fromBinaryTime(v)
                    case _ => 
                        throw ValueConvertException("Unsupported conversion from ${columnType} to DateTime")
        }
        }
    

    }

    public override func getInputStream(index: Int64): ?InputStream {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => return ByteBuffer(v)
        }
    }

    @OverflowWrapping
    public override func getString(index: Int64): ?String {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                let unsigned = getFieldIsUnsigned(index)
                match (columnType) {
                    case Tiny =>
                        if (!unsigned) {
                            return getInt8(index).getOrThrow().toString()
                        } else {
                            return getUInt8(index).getOrThrow().toString()
                        }
                    case Short | Year =>
                        if (!unsigned) {
                            return getInt16(index).getOrThrow().toString()
                        } else {
                         return getUInt16(index).getOrThrow().toString()
                        }
                    case Long | Int24 =>
                        if (!unsigned) {
                            return getInt32(index).getOrThrow().toString()
                        } else {
                            return getUInt32(index).getOrThrow().toString()
                        }
                    case LongLong =>
                        if (!unsigned) {
                            return getInt64(index).getOrThrow().toString()
                        } else {
                        return getUInt64(index).getOrThrow().toString()
                        }
                    case Float => 
                        return getFloat32(index).getOrThrow().toString()
                    case Double => 
                        return getFloat64(index).getOrThrow().toString()
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
                        return getDate(index).getOrThrow().toString(DB_DATE_FORMAT)
                    case DateTime | Timestamp => 
                        return getDateTime(index).getOrThrow().toString(DB_DATE_TIME_FORMAT)
                    case Time => 
                        return getTime(index).getOrThrow().toString(DB_TIME_FORMAT)
                        //case _ => throw Exception("Unsupport MySQL binary type")
                    }
        }

    }

    public override func getArray(index: Int64): ?Array<Byte> {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = getFieldType(index)
                match (columnType) {
                    case String | VarString | Json | Enum | Set | TinyBlob | Blob | MediumBlob | LongBlob => 
                        return v
                    case _ => 
                        throw UnsupportedException("Unsupported database type ${columnType} convert to Array")
                }
        }
    }

    public override func getJsonValue(index: Int64): ?JsonValue {
        match (getString(index)) {
            case None => return None
            case Some(v) => return JsonValue.fromStr(v)
        }
    }

    public override func getFieldType(index: Int64): ColumnType {
        return columns[index - 1].columnType
    }

    public override func getFieldName(index: Int64): String {
        return columns[index - 1].name
    }

    public override func getFieldDecimal(index: Int64): Byte {
        return columns[index - 1].decimals
    }

    public override func getFieldIsNotNull(index: Int64): Bool {
        return columns[index - 1].hasFlag(NotNull)
    }

    public override func getFieldIsUnsigned(index: Int64): Bool {
        return columns[index - 1].hasFlag(Unsigned)
    }

    public override func getFieldLength(index: Int64): UInt32 {
        return columns[index - 1].columnLength
    }

    public override func getFieldCharset(index: Int64): Charset {
        return columns[index - 1].charset
    }

    private func getBinaryData(index: Int64): ?Array<Byte> {
        return this.rows[currentRow - 1][index - 1]
    }
}
