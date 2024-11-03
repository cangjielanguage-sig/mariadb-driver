/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.result

import std.time.*
import std.convert.*
import std.io.*
import encoding.json.*
import std.math.numeric.*
import std.collection.*
import mysqlclient4cj.protocol.*

protected class TextResultSet <: ResultSet {

    private var _columns: Array<ColumnDefinition>

    private var _rows: Array<TextResult>

    private var _currentRow: Int64

    private var _indexMap: Map<String, Int64>

    protected TextResultSet(fields: Array<ColumnDefinition>, rows: Array<TextResult>) {
        _columns = fields
        _rows = rows
        _currentRow = 0
        _indexMap = HashMap<String, Int64>()
        for(i in 0.._columns.size){
            _indexMap.put(_columns[i].name, i + 1)
        }
    }
    
    public override prop rowSize: Int64 {
        get() {
            _rows.size
        }
    }

    public override prop columnSize: Int64 {
        get() {
            _columns.size
        }
    }

    public func next(): Bool {
        if (_currentRow >= rowSize) {
            return false
        } else {
            _currentRow++
            return true
        }
    }

    public override func getIndexByName(name: String): Int64 {
        return _indexMap.get(name).getOrThrow()
    }

    public override func getBool(index: Int64): ?Bool {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToBool(v)
        }
    }

    public override func getInt8(index: Int64): ?Int8 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToInt8(index, v)
        }
    }

    public override func getUInt8(index: Int64): ?UInt8 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToUInt8(index, v)
        }
    }

    public override func getInt16(index: Int64): ?Int16 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToInt16(index, v)
        }
    }

    public override func getUInt16(index: Int64): ?UInt16 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToUInt16(index, v)
        }
    }

    public override func getInt32(index: Int64): ?Int32 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToInt32(index, v)
        }
    }

    public override func getUInt32(index: Int64): ?UInt32 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToUInt32(index, v)
        }
    }

    public override func getInt64(index: Int64): ?Int64 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToInt64(index, v)
        }
    }

    public override func getUInt64(index: Int64): ?UInt64 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToUInt64(index, v)
        }
    }

    public override func getFloat16(index: Int64): ?Float16 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToFloat16(index, v)
        }
    }

    public override func getFloat32(index: Int64): ?Float32 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToFloat32(index, v)
        }
    }

    public override func getFloat64(index: Int64): ?Float64 {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToFloat64(index, v)
        }
    }

    public override func getBigInt(index: Int64): ?BigInt {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToBigInt(index, v)
        }
    }

    public override func getDecimal(index: Int64): ?Decimal {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToDecimal(index, v)
        }
    }

    public override func getDate(index: Int64): ?DateTime {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToDate(index, v)
        }
    }

    public override func getTime(index: Int64): ?DateTime {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToTime(index, v)
        }
    }

    public override func getDateTime(index: Int64): ?DateTime {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToDateTime(index, v)
        }
    }

    public override func getTimestamp(index: Int64): ?DateTime {
        match (getString(index)) {
            case None => None
            case Some(v) => stringParseToDateTime(index, v)
        }
    }

    public override func getInputStream(index: Int64): ?InputStream {
        match (getArray(index)) {
            case None => None
            case Some(v) => arrayToInputStream(v)
        }
    }

    public override func getString(index: Int64): ?String {
        match (getArray(index)) {
            case None => None
            case Some(v) => String.fromUtf8(v)
        }
    }

    public override func getArray(index: Int64): ?Array<Byte> {
        return _rows[_currentRow - 1].row[index - 1]
    }

    public func getJsonValue(index: Int64): ?JsonValue {
        match (getString(index)) {
            case None => None
            case Some(v) => JsonValue.fromStr(v)
        }
    }

    public override func getFieldType(index: Int64): ColumnType {
        return _columns[index - 1].columnType
    }

    public override func getFieldName(index: Int64): String {
        return _columns[index - 1].name
    }

    public override func getFieldDecimal(index: Int64): Byte {
        return _columns[index - 1].decimals
    }

    public override func getFieldIsNotNull(index: Int64): Bool {
        return _columns[index - 1].hasFlag(NotNull)
    }

    public override func getFieldIsUnsigned(index: Int64): Bool {
        return _columns[index - 1].hasFlag(Unsigned)
    }

    public override func getFieldCharset(index: Int64): Charset {
        return _columns[index - 1].charset
    }

    public override func getFieldLength(index: Int64): UInt32 {
        return _columns[index - 1].columnLength
    }

    private func stringParseToBool(str: String): Bool {
        if (str == "1") {
            return true
        } else {
            return false
        }
    }

    private func stringParseToInt8(index: Int64, str: String): Int8 {
        try {
            return Int8.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Int8 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToUInt8(index: Int64, str: String): UInt8 {
        try {
            return UInt8.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt8 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToInt16(index: Int64, str: String): Int16 {
        try {
            return Int16.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Int16 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToUInt16(index: Int64, str: String): UInt16 {
        try {
            return UInt16.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt16 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToInt32(index: Int64, str: String): Int32 {
        try {
            return Int32.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Int32 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToUInt32(index: Int64, str: String): UInt32 {
        try {
            return UInt32.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt32 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToInt64(index: Int64, str: String): Int64 {
        try {
            return Int64.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Int64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToUInt64(index: Int64, str: String): UInt64 {
        try {
            return UInt64.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToFloat16(index: Int64, str: String): Float16 {
        try {
            return Float16.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float16 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToFloat32(index: Int64, str: String): Float32 {
        try {
            return Float32.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float32 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToFloat64(index: Int64, str: String): Float64 {
        try {
            return Float64.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToBigInt(index: Int64, str: String): ?BigInt {
        try {
            return BigInt(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to BigInt failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToDecimal(index: Int64, str: String): Decimal {
        try {
            return Decimal(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToDate(index: Int64, str: String): DateTime {
        try {
            return DateTime.parse(str, DB_DATE_FORMAT)
        } catch (e: TimeParseException) {
            throw ValueConvertException("Parse to Date failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToTime(index: Int64, str: String): DateTime {
        try {
            return DateTime.parse(DB_TIME_PREFIX + str, DB_DATE_TIME_FORMAT)
        } catch (e: TimeParseException) {
            throw ValueConvertException("Parse to Time failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    }

    private func stringParseToDateTime(index: Int64, str: String): DateTime {
        try {
            return DateTime.parse(str, DB_DATE_TIME_FORMAT)
        } catch (e: TimeParseException) {
            throw ValueConvertException("Parse to DateTime failed: column name is '${getFieldName(index)}', raw value is ${str}")
        }
    } 
}
