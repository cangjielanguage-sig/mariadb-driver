/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc.impl

import std.math.numeric.{Decimal, BigInt}
import std.time.DateTime
import std.io.InputStream
import encoding.json.JsonValue
import cjmd.result.*
import cjmd.jdbc.*

public class QueryResultImpl <: QueryResult {

    private var resultSet: ResultSet

    protected init(resultSet: ResultSet) {
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

    override public func getBigInt(index: Int64): ?BigInt {
        return resultSet.getBigInt(index)
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
        return resultSet.getBool(getIndexByName(name))
    }

    override public func getInt8(name: String): ?Int8 {
        return resultSet.getInt8(getIndexByName(name))
    }

    override public func getUInt8(name: String): ?UInt8 {
        return resultSet.getUInt8(getIndexByName(name))
    }

    override public func getInt16(name: String): ?Int16 {
        return resultSet.getInt16(getIndexByName(name))
    }
    
    override public func getUInt16(name: String): ?UInt16 {
        return resultSet.getUInt16(getIndexByName(name))
    }

    override public func getInt32(name: String): ?Int32 {
        return resultSet.getInt32(getIndexByName(name))
    }

    override public func getUInt32(name: String): ?UInt32 {
        return resultSet.getUInt32(getIndexByName(name))
    }

    override public func getInt64(name: String): ?Int64 {
        return resultSet.getInt64(getIndexByName(name))
    }

    override public func getUInt64(name: String): ?UInt64 {
        return resultSet.getUInt64(getIndexByName(name))
    }

    override public func getFloat16(name: String): ?Float16 {
        return resultSet.getFloat16(getIndexByName(name))
    }

    override public func getFloat32(name: String): ?Float32 {
        return resultSet.getFloat32(getIndexByName(name))
    }

    override public func getFloat64(name: String): ?Float64 {
        return resultSet.getFloat64(getIndexByName(name))
    }   

    override public func getDecimal(name: String): ?Decimal {
        return resultSet.getDecimal(getIndexByName(name))
    }

    override public func getBigInt(name: String): ?BigInt {
        return resultSet.getBigInt(getIndexByName(name))
    }

    override public func getDate(name: String): ?Date {
        match (resultSet.getDate(getIndexByName(name))) {
            case None => None
            case Some(v) => Date(v)
        }
    }

    override public func getTime(name: String): ?Time {
        match (resultSet.getTime(getIndexByName(name))) {
            case None => None
            case Some(v) => Time(v)
        }
    }

    override public func getDateTime(name: String): ?DateTime {
        return resultSet.getDateTime(getIndexByName(name))
    }

    override public func getTimestamp(name: String): ?DateTime {
        return resultSet.getTimestamp(getIndexByName(name))
    }

    override public func getInputStream(name: String): ?InputStream {
        return resultSet.getInputStream(getIndexByName(name))
    }

    override public func getString(name: String): ?String {
        return resultSet.getString(getIndexByName(name))
    }

    override public func getArray(name: String): ?Array<Byte> {
        return resultSet.getArray(getIndexByName(name))
    }

    override public func getJsonValue(name: String): ?JsonValue {
        return resultSet.getJsonValue(getIndexByName(name))
    }


    override public func close(){
    }
    
    override public func isClosed(): Bool{
        return true
    }

    private func getIndexByName(name: String): Int64 {
        try{
            return resultSet.getIndexByName(name)
        }catch (e: Exception) {
            throw SqlException(e.message)
        }
    }

}