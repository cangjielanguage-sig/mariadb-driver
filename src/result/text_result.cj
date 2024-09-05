/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.result

import std.time.*
import std.convert.*
import std.io.*
import encoding.json.*
import cjmd.packet.*
import std.math.numeric.*

public class PlainResult <: TabularResult {

    private var _columns: Array<ColumnDefinition>

    private var _rows: Array<TextResult>

    private var _currentRow: Int64

    protected PlainResult(fields: Array<ColumnDefinition>, rows: Array<TextResult>) {
        _columns = fields
        _rows = rows
        _currentRow = 0
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
        if(_currentRow >= rowSize){
            return false
        }else {
            _currentRow ++
            return true
        }
    }

    public override func getBool(index: Int64): ?Bool {
        var val = getString(index)
        if(val.isNone()){
            return None
        }
        if(val == "1"){return true}else {return false}
    }

    public override func getInt8(index: Int64): ?Int8 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Int8.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Int8 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getUInt8(index: Int64): ?UInt8 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return UInt8.parse(val.getOrThrow())
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to UInt8 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getInt16(index: Int64): ?Int16 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Int16.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Int16 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getUInt16(index: Int64): ?UInt16 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return UInt16.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to UInt16 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getInt32(index: Int64): ?Int32 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Int32.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Int32 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getUInt32(index: Int64): ?UInt32 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return UInt32.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to UInt32 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getInt64(index: Int64): ?Int64 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Int64.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Int64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getUInt64(index: Int64): ?UInt64 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return UInt64.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to UInt64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getFloat16(index: Int64): ?Float16 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Float16.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Float16 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getFloat32(index: Int64): ?Float32 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Float32.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Float32 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getFloat64(index: Int64): ?Float64 {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Float64.parse(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Float64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }

    public override func getDecimal(index: Int64): ?Decimal {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return Decimal(str)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Float64 failed: column name is '${getFieldName(index)}', raw value is ${str}")
            }
        }
    }


    public override func getDate(index: Int64): ?DateTime {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return DateTime.parse(str, DB_DATE_FORMAT)
            }catch (e: TimeParseException) {
                throw ValueConvertException("Parse to Date failed: ${e.message} column name is '${getFieldName(index)}', raw value is ${str}.")
            }
        }
    }

    public override func getTime(index: Int64): ?DateTime {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return DateTime.parse(DB_TIME_PREFIX + val.getOrThrow(), DB_DATE_TIME_FORMAT)
            }catch (e: TimeParseException) {
                throw ValueConvertException("Parse to Time failed: ${e.message} column name is '${getFieldName(index)}', raw value is ${str}.")
            }
        }
    }

    public override func getDateTime(index: Int64): ?DateTime {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return DateTime.parse(str, DB_DATE_TIME_FORMAT)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Time failed: ${e.message} column name is '${getFieldName(index)}', raw value is ${str}.")
            }  
        }
    }

    public override func getTimestamp(index: Int64): ?DateTime {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else{
            var str = val.getOrThrow()
            try {
                return DateTime.parse(str, DB_DATE_TIME_FORMAT)
            }catch (e: IllegalArgumentException) {
                throw ValueConvertException("Parse to Time failed: ${e.message} column name is '${getFieldName(index)}', raw value is ${str}.")
            }  
        }
    }

    public override func getInputStream(index: Int64): ?InputStream {
        var value = _rows[_currentRow - 1].row[index - 1]
        if(value.isNone()){
            return None
        }else{
            var stream = ByteArrayStream()
            stream.write(value.getOrThrow())
            return stream
        }
    }

    public override func getString(index: Int64): ?String {
        var value = _rows[_currentRow - 1].row[index - 1]
        if(value.isNone()){
            return None
        }else {
            return String.fromUtf8(value.getOrThrow())
        }
    }

    public override func getArray(index: Int64): ?Array<Byte> {
        var value = _rows[_currentRow - 1].row[index - 1]
        if(value.isNone()){
            return None
        }else{
            return value.getOrThrow()
        }
    }

    public func getJsonObject(index: Int64): ?JsonObject {
        var val = getString(index)
        if(val.isNone()){
            return None
        }else {
            return JsonObject.fromStr(val.getOrThrow()).asObject()
        }
    }

    public override func getFieldType(index: Int64): ColumnType {
        return _columns[index - 1].columnType
    }

    public override func getFieldName(index: Int64): String {
        return _columns[index - 1].name
    }

    public override func getFieldDecimal(index: Int64): Byte{
        return _columns[index - 1].decimals
    }

    public override func getFieldIsNotNull(index: Int64): Bool{
        return _columns[index - 1].hasFlag(NotNull)
    }

    public override func getFieldIsUnsigned(index: Int64): Bool{
        return _columns[index - 1].hasFlag(Unsigned)
    }

    public override func getFieldCharset(index: Int64): Charset {
        return _columns[index - 1].charset
    }

    public override func getFieldLength(index: Int64): UInt32{
        return _columns[index - 1].fieldLength
    }

}