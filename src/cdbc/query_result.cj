package cjmd.cdbc

import cdbc.*
import cjmd.result.*
import std.math.numeric.Decimal
import std.time.DateTime
import std.io.InputStream
import std.io.ByteArrayStream
import encoding.json.JsonValue
import std.collection.concurrent.NonBlockingQueue

public class QueryResultImpl <: QueryResult {

    private var resultSet: ResultSet

    public init(resultSet: ResultSet) {
        this.resultSet = resultSet
    }

    override public prop rowSize: Int64 {
        get() {
            resultSet.rowSize
        }
    }

    override public prop columnSize: Int64 {
        get() {
            resultSet.columnSize
        }
    }

    override public func next(): Bool {
        return resultSet.next()
    }

    override public func getBool(index: Int64): ?Bool {
        return resultSet.getBool(index)
    }

    override public func getInt8(index: Int64): ?Int8 {
        return resultSet.getInt8(index)
    }

    override public func getUInt8(index: Int64): ?UInt8 {
        return resultSet.getUInt8(index)
    }

    override public func getInt16(index: Int64): ?Int16 {
        return resultSet.getInt16(index)
    }
    
    override public func getUInt16(index: Int64): ?UInt16 {
        return resultSet.getUInt16(index)
    }

    override public func getInt32(index: Int64): ?Int32 {
        return resultSet.getInt32(index)
    }

    override public func getUInt32(index: Int64): ?UInt32 {
        return resultSet.getUInt32(index)
    }

    override public func getInt64(index: Int64): ?Int64 {
        return resultSet.getInt64(index)
    }

    override public func getUInt64(index: Int64): ?UInt64 {
        return resultSet.getUInt64(index)
    }

    override public func getFloat16(index: Int64): ?Float16 {
        return resultSet.getFloat16(index)
    }

    override public func getFloat32(index: Int64): ?Float32 {
        return resultSet.getFloat32(index)
    }

    override public func getFloat64(index: Int64): ?Float64 {
        return resultSet.getFloat64(index)
    }

    override public func getDecimal(index: Int64): ?Decimal {
        return resultSet.getDecimal(index)
    }

    override public func getDate(index: Int64): ?Date {
        match (resultSet.getDate(index)) {
            case None => None
            case Some(v) => Date(v)
        }
    }

    override public func getTime(index: Int64): ?Time {
        match (resultSet.getTime(index)) {
            case None => None
            case Some(v) => Time(v)
        }
    }

    override public func getDateTime(index: Int64): ?DateTime {
        return resultSet.getDateTime(index)
    }

    override public func getTimestamp(index: Int64): ?DateTime {
        return resultSet.getDateTime(index)
    }

    override public func getInputStream(index: Int64): ?InputStream {
        return resultSet.getInputStream(index)
    }

    override public func getString(index: Int64): ?String {
        return resultSet.getString(index)
    }

    override public func getArray(index: Int64): ?Array<Byte> {
        return resultSet.getArray(index)
    }

    override public func getJsonValue(index: Int64): ?JsonValue {
        return resultSet.getJsonValue(index)
    }

    override public func getBool(name: String): ?Bool {
        return true
    }

    override public func getInt8(name: String): ?Int8 {
        return 0i8
    }

    override public func getUInt8(name: String): ?UInt8 {
        return 0u8
    }

    override public func getInt16(name: String): ?Int16 {
        return 0i16
    }
    
    override public func getUInt16(name: String): ?UInt16 {
        return 0u16
    }

    override public func getInt32(name: String): ?Int32 {
        return 0i32
    }

    override public func getUInt32(name: String): ?UInt32 {
        return 0u32
    }

    override public func getInt64(name: String): ?Int64 {
        return 0i64
    }

    override public func getUInt64(name: String): ?UInt64 {
        return 0u64
    }

    override public func getFloat16(name: String): ?Float16 {
        return 0.00f16
    }

    override public func getFloat32(name: String): ?Float32 {
        return 0.00f32
    }

    override public func getFloat64(name: String): ?Float64 {
        return 0.00f64
    }   

    override public func getDecimal(name: String): ?Decimal {
        return Decimal(0.00)
    }

    override public func getDate(name: String): ?Date {
        return Date(DateTime.now())
    }

    override public func getTime(name: String): ?Time {
        return Time(DateTime.now())
    }

    override public func getDateTime(name: String): ?DateTime {
        return DateTime.now()
    }

    override public func getTimestamp(name: String): ?DateTime {
        return DateTime.now()
    }

    override public func getInputStream(name: String): ?InputStream {
        return ByteArrayStream()
    }

    override public func getString(name: String): ?String {
        return ""
    }

    override public func getArray(name: String): ?Array<Byte> {
        return []
    }

    override public func getJsonValue(name: String): ?JsonValue {
        return JsonValue.fromStr("")
    }


    override public func close(){
    }
    
    override public func isClosed(): Bool{
        return true
    }

}