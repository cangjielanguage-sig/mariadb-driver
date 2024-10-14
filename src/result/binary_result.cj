/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.result

import std.time.*
import std.convert.*
import std.io.*
import std.math.numeric.*
import std.collection.Map
import std.collection.HashMap
import encoding.json.*
import mysqlclient4cj.protocol.*

protected class BinaryResultSet <: ResultSet {

    private var columns: Array<ColumnDefinition>

    private var rows: Array<BinaryResult>

    private var currentRow: Int64

    private var indexMap: Map<String, Int64>

    protected BinaryResultSet(columns: Array<ColumnDefinition>, rows: Array<BinaryResult>) {
        this.columns = columns
        this.rows = rows
        this.currentRow = 0
        indexMap = HashMap<String, Int64>()
        for(i in 0..columns.size){
            indexMap.put(columns[i].name, i + 1)
        }
    }
    
    public override prop rowSize: Int64 {
        get() {
            rows.size
        }
    }

    public override prop columnSize: Int64 {
        get() {
            columns.size
        }
    }

    public func next(): Bool {
        if(currentRow >= rowSize){
            return false
        }else {
            currentRow ++
            return true
        }
    }

    public override func getIndexByName(name: String): Int64 {
        return indexMap.get(name).getOrThrow()
    }

    public override func getBool(index: Int64): ?Bool {
        var val = getString(index)
        if(val.isNone()){
            return None
        }
        if(val == "1"){return true}else {return false}
    }

    @OverflowWrapping
    public override func getInt8(index: Int64): ?Int8 {
        match (getUInt8(index)) {
            case Some(v) => Int8(v)
            case None => None
        }
    }

    public override func getUInt8(index: Int64): ?UInt8 {
        match (getUInt64(index)) {
            case Some(v) => UInt8(v)
            case None =>  None
        }
    }

    @OverflowWrapping
    public override func getInt16(index: Int64): ?Int16 {
        match (getUInt16(index)) {
            case Some(v) => Int16(v)
            case None => None
        }
    }

    public override func getUInt16(index: Int64): ?UInt16 {
        match (getUInt64(index)) {
            case Some(v) => UInt16(v)
            case None => None
        }
    }

    @OverflowWrapping
    public override func getInt32(index: Int64): ?Int32 {
        match (getUInt32(index)) {
            case Some(v) => Int32(v)
            case None => None
        }
    }

    public override func getUInt32(index: Int64): ?UInt32 {
        match (getUInt64(index)) {
            case Some(v) => UInt32(v)
            case None => None
        }
    }

    @OverflowWrapping
    public override func getInt64(index: Int64): ?Int64 {
        match (getUInt64(index)) {
            case Some(v) => Int64(v)
            case None => None
        }
    }

    public override func getUInt64(index: Int64): ?UInt64 {
        var columnType = getFieldType(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        var data = dataOp.getOrThrow()
        match (columnType) {
            case Tiny => return UInt64(data[0])
            case Short | Year => return UInt64(littleEndianToUInt16(data))
            case Long | Int24 => return UInt64(littleEndianToUInt32(data))
            case LongLong => return littleEndianToUInt64(data)
            case Float => 
                return UInt64(getFloat32(index).getOrThrow())
            case Double => 
                return UInt64(getFloat64(index).getOrThrow())
            case String | VarString | NewDecimal => 
                var str = getString(index).getOrThrow()
                try {
                    return UInt64.parse(str)
                }catch (e: IllegalArgumentException) {
                    throw ValueConvertException("Parse to Integer failed: column name is '${getFieldName(index)}', raw value is ${str}")
                }
            case _ => throw ValueConvertException("Unsupported conversion from ${columnType} to Integer")
        }
    }

    public override func getFloat16(index: Int64): ?Float16 {
        match (getFloat32(index)) {
            case None => None
            case Some(v) => return Float16(v)
        }
    }

    public override func getFloat32(index: Int64): ?Float32 {
        var columnType = getFieldType(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        var data = dataOp.getOrThrow()
        match (columnType) {
            case Float => return littleEndianToFloat32(data)
            case Double => return Float32(getFloat64(index).getOrThrow())
            case String | VarString => return Float32.parse(getString(index).getOrThrow())
            case _ => throw ValueConvertException("Unsupported conversion from ${columnType} to Integer")
        }
    }

    public override func getFloat64(index: Int64): ?Float64 {
        var columnType = getFieldType(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        var data = dataOp.getOrThrow()
        match (columnType) {
            case Float => return Float64(getFloat32(index).getOrThrow())
            case Double => return littleEndianToFloat64(data)
            case String | VarString | NewDecimal => return Float64.parse(getString(index).getOrThrow())
            case _ => throw ValueConvertException("Unsupported conversion from ${columnType} to Integer")
        }
    }

    public override func getBigInt(index: Int64): ?BigInt {
        var columnType = getFieldType(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        //var data = dataOp.getOrThrow()
        match (columnType) {
            case Tiny => return BigInt(getInt8(index).getOrThrow())
            case Short | Year => return BigInt(getInt16(index).getOrThrow())
            case Int24 | Long => return BigInt(getInt32(index).getOrThrow())
            case LongLong => return BigInt(getInt64(index).getOrThrow())
            case String | VarString => return BigInt(getString(index).getOrThrow())
            case _ => throw ValueConvertException("Unsupported conversion from ${columnType} to BigInt")
        }
    }

    public func getDecimal(index: Int64): ?Decimal {
        var columnType = getFieldType(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        match (columnType) {
            case Float => return Decimal(getFloat32(index).getOrThrow())
            case Double => return Decimal(getFloat64(index).getOrThrow())
            case String | VarString | NewDecimal => Decimal(getString(index).getOrThrow())
            case _ => throw ValueConvertException("Unsupported conversion from ${columnType} to Integer")
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
        var columnType = getFieldType(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        var data = dataOp.getOrThrow()
        match (columnType) {
            case Date => return binaryDateTimeToDateTime(data)
            case DateTime | Timestamp => return binaryDateTimeToDateTime(data)
            case Time => return binaryTimeToDateTime(data)
            case _ => throw ValueConvertException("Unsupported conversion from ${columnType} to DateTime")
        }
    }

    public override func getInputStream(index: Int64): ?InputStream {
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        var data = dataOp.getOrThrow()
        var stream = ByteArrayStream()
        stream.write(data)
        return stream
    }

    @OverflowWrapping
    public override func getString(index: Int64): ?String {
        var columnType = getFieldType(index)
        var unsigned = getFieldIsUnsigned(index)
        //var charset = getFieldCharset(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        var data = dataOp.getOrThrow()
        match (columnType) {
            case Tiny => 
                if(!unsigned){
                    return getInt8(index).getOrThrow().toString()
                }else{
                    return getUInt8(index).getOrThrow().toString()
                }
            case Short | Year =>
                if(!unsigned){
                    return getInt16(index).getOrThrow().toString()
                }else{
                    return getUInt16(index).getOrThrow().toString()
                }
            case Long | Int24 =>
                if(!unsigned){
                    return getInt32(index).getOrThrow().toString()
                }else{
                    return getUInt32(index).getOrThrow().toString()
                }
            case LongLong =>
                if(!unsigned){
                    return getInt64(index).getOrThrow().toString()
                }else{
                    return getUInt64(index).getOrThrow().toString()
                }
            case Float => 
                return getFloat32(index).getOrThrow().toString()
            case Double =>
                return getFloat64(index).getOrThrow().toString()
            case NewDecimal =>
                return String.fromUtf8(data)
            case String | Json | Enum | Set | TinyBlob | MediumBlob | LongBlob | Blob | VarString => 
                // match (charset) {
                //     case Binary => 
                //         throw Exception("Unsupported Charset: Binary")
                //     case Utf8mb3GeneralCi => 
                //         return String.fromUtf8(data)
                //     case Latin1SwedishCi => 
                //         throw Exception("Unsupported Charset: Latin1SwedishCi")
                // }
                return String.fromUtf8(data)
            case Date => 
                return getDate(index).getOrThrow().toString(DB_DATE_FORMAT)
            case DateTime | Timestamp => 
                return getDateTime(index).getOrThrow().toString(DB_DATE_TIME_FORMAT)
            case Time => 
                return getTime(index).getOrThrow().toString(DB_TIME_FORMAT)
            case _ => throw Exception("Unsupport MySQL binary type")
        }
    }

    public override func getArray(index: Int64): ?Array<Byte> {
        var columnType = getFieldType(index)
        var dataOp = getBinaryData(index)
        if(dataOp.isNone()){
            return None
        }
        var data = dataOp.getOrThrow()
        match (columnType) {
            case String | VarString | Json | Enum | Set | TinyBlob | Blob | MediumBlob | LongBlob =>
                return data
            case _ => throw UnsupportedException("Unsupported database type ${columnType} convert to Array")
        }
    }

    public override func getJsonValue(index: Int64): ?JsonValue {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else {
            return JsonValue.fromStr(val.getOrThrow())
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
        return columns[index - 1].fieldLength
    }

    public override func getFieldCharset(index: Int64): Charset {
        return columns[index - 1].charset
    }

    private func getBinaryData(index: Int64): ?Array<Byte> {
        return this.rows[currentRow - 1].binaryData[index - 1]
    }
}