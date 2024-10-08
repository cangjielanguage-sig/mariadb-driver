/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc.impl

import std.time.DateTime
import std.math.numeric.{Decimal, BigInt}
import std.io.InputStream
import std.collection.ArrayList
import encoding.json.JsonValue
import cjmd.jdbc.*

public abstract class AllocateStatement <: Statement {

    private var sql: String

    private var paramsAllocator: ArrayList<Any>

    public init(originSql: String) {
        this.sql = originSql
        this.paramsAllocator =  ArrayList<Any>(originSql.count("?"), {_ => Option<Any>.None})
    }

    public prop params: Array<Any> {
        get() {
            paramsAllocator.toArray()
        }
    }

    public prop originSql: String {
        get() {
            sql
        }
    }

    override public func setNull(paramIndex: Int64): Unit {
        setParams(paramIndex, Option<Any>.None)
    }

    override public func setString(paramIndex: Int64, value: String): Unit{
        setParams(paramIndex, value)
    }

    override public func setBool(paramIndex: Int64, value: Bool): Unit {
        setParams(paramIndex, value)
    }

    override public func setInt8(paramIndex: Int64, value: Int8): Unit {
        setParams(paramIndex, value)
    }

    override public func setUInt8(paramIndex: Int64, value: UInt8): Unit {
        setParams(paramIndex, value)
    }

    override public func setInt16(paramIndex: Int64, value: Int16): Unit {
        setParams(paramIndex, value)
    }

    override public func setUInt16(paramIndex: Int64, value: UInt16): Unit {
        setParams(paramIndex, value)
    }

    override public func setInt32(paramIndex: Int64, value: Int32): Unit {
        setParams(paramIndex, value)
    }

    override public func setUInt32(paramIndex: Int64, value: UInt32): Unit {
        setParams(paramIndex, value)
    }

    override public func setInt64(paramIndex: Int64, value: Int64): Unit {
        setParams(paramIndex, value)
    }

    override public func setUInt64(paramIndex: Int64, value: UInt64): Unit {
        setParams(paramIndex, value)
    }

    override public func setFloat16(paramIndex: Int64, value: Float16): Unit {
        setParams(paramIndex, value)
    }

    override public func setFloat32(paramIndex: Int64, value: Float16): Unit {
        setParams(paramIndex, value)
    }

    override public func setFloat64(paramIndex: Int64, value: Float16): Unit {
        setParams(paramIndex, value)
    }

    override public func setBigInt(paramIndex: Int64, value: BigInt): Unit {
        setParams(paramIndex, value)
    }

    override public func setDecimal(paramIndex: Int64, value: Decimal): Unit {
        setParams(paramIndex, value)
    }

    override public func setDate(paramIndex: Int64, value: Date): Unit {
        setParams(paramIndex, value)
    }

    override public func setTime(paramIndex: Int64, value: Time): Unit {
        setParams(paramIndex, value)
    }

    override public func setDateTime(paramIndex: Int64, value: DateTime): Unit {
        setParams(paramIndex, value)
    }

    override public func setTimestamp(paramIndex: Int64, value: DateTime): Unit {
        setParams(paramIndex, value)
    }

    override public func setArray(paramIndex: Int64, value: Array<Byte>): Unit {
        setParams(paramIndex, value)
    }

    override public func setInputStream(paramIndex: Int64, value: InputStream): Unit {
        setParams(paramIndex, value)
    }

    override public func setJson(paramIndex: Int64, value: JsonValue): Unit {
        setParams(paramIndex, value)
    }

    public func setParams(paramsIndex: Int64, value: Any): Unit {
        paramsAllocator.set(paramsIndex - 1, value)
    }

    public func getParamsCount(){
        return originSql.count("?")
    }
}