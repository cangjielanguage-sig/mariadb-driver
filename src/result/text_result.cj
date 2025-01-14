/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.result

import std.time.DateTime
import std.time.TimeParseException
import std.io.ByteBuffer
import std.io.InputStream
import std.math.numeric.BigInt
import std.math.numeric.Decimal
import std.convert.Parsable
import std.collection.HashMap
import encoding.json.JsonValue
import mysql.protocol.*
import mysql.protocol.response.*

protected class TextResultSet <: ResultSet {

    private let columns: Array<ColumnDefinition>

    private let rows: Array<TextResult>

    private let indexMap: HashMap<String, Int64>

    private var currentRow: Int64

    protected TextResultSet(columns: Array<ColumnDefinition>, rows: Array<TextResult>) {
        this.columns = columns
        this.rows = rows
        this.currentRow = 0
        this.indexMap = HashMap<String, Int64>()
        for(i in 0..columns.size){
            indexMap.add(columns[i].name, i + 1)
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
            case Some(v) => ByteBuffer(v)
        }
    }

    public override func getString(index: Int64): ?String {
        match (getArray(index)) {
            case None => None
            case Some(v) => String.fromUtf8(v)
        }
    }

    public override func getArray(index: Int64): ?Array<Byte> {
        return rows[currentRow - 1].row[index - 1]
    }

    public func getJsonValue(index: Int64): ?JsonValue {
        match (getString(index)) {
            case None => None
            case Some(v) => JsonValue.fromStr(v)
        }
    }

    public override func metadata(index: Int64): ColumnDefinition {
        return columns[index - 1]
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
            throw ValueConvertException("Parse to Int8 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToUInt8(index: Int64, str: String): UInt8 {
        try {
            return UInt8.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt8 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToInt16(index: Int64, str: String): Int16 {
        try {
            return Int16.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Int16 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToUInt16(index: Int64, str: String): UInt16 {
        try {
            return UInt16.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt16 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToInt32(index: Int64, str: String): Int32 {
        try {
            return Int32.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Int32 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToUInt32(index: Int64, str: String): UInt32 {
        try {
            return UInt32.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt32 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToInt64(index: Int64, str: String): Int64 {
        try {
            return Int64.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Int64 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToUInt64(index: Int64, str: String): UInt64 {
        try {
            return UInt64.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to UInt64 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToFloat16(index: Int64, str: String): Float16 {
        try {
            return Float16.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float16 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToFloat32(index: Int64, str: String): Float32 {
        try {
            return Float32.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float32 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToFloat64(index: Int64, str: String): Float64 {
        try {
            return Float64.parse(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float64 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToBigInt(index: Int64, str: String): ?BigInt {
        try {
            return BigInt(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to BigInt failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToDecimal(index: Int64, str: String): Decimal {
        try {
            return Decimal(str)
        } catch (e: IllegalArgumentException) {
            throw ValueConvertException("Parse to Float64 failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToDate(index: Int64, str: String): DateTime {
        try {
            return DateTime.parse(str, DB_DATE_FORMAT)
        } catch (e: TimeParseException) {
            throw ValueConvertException("Parse to Date failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToTime(index: Int64, str: String): DateTime {
        try {
            return DateTime.parse(DB_TIME_PREFIX + str, DB_DATE_TIME_FORMAT)
        } catch (e: TimeParseException) {
            throw ValueConvertException("Parse to Time failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    }

    private func stringParseToDateTime(index: Int64, str: String): DateTime {
        try {
            return DateTime.parse(str, DB_DATE_TIME_FORMAT)
        } catch (e: TimeParseException) {
            throw ValueConvertException("Parse to DateTime failed: column name is '${metadata(index).name}', raw value is ${str}")
        }
    } 
}
