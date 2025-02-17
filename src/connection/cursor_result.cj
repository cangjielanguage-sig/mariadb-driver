/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.connection

import std.io.*
import std.time.*
import std.math.numeric.*
import encoding.json.*
import mysql.result.*
import mysql.protocol.*
import mysql.protocol.response.*

protected class CursorResultSet <: ResultSet {

    private let prepareId: UInt32

    private let columns: Array<ColumnDefinition>

    private let connection: MySqlConnection

    private let fetchSize: UInt32

    private var resultSet: ResultSet

    protected CursorResultSet(prepareId: UInt32, columns: Array<ColumnDefinition>, fetchSize: UInt32, connection: MySqlConnection) {
        this.prepareId = prepareId
        this.columns = columns
        this.connection = connection
        this.fetchSize = fetchSize
        this.resultSet = connection.fetchRows(prepareId, columns, fetchSize)
    }


    public prop columnDefinitions: Array<ColumnDefinition> {
        get() {
            columns
        }
    }

    public override func next(): Bool {
        if(!resultSet.next()) {
            //如果当前拉取的结果集被读完, 尝试拉取下一个结果集
            resultSet = connection.fetchRows(prepareId, columns, fetchSize)
            return resultSet.next()
        }
        return true
    }


    public override func getBool(index: Int64): ?Bool {
        return resultSet.getBool(index)
    }

    public override func getInt8(index: Int64): ?Int8 {
        return resultSet.getInt8(index)
    }

    public override func getUInt8(index: Int64): ?UInt8 {
        return resultSet.getUInt8(index)
    }

    public override func getInt16(index: Int64): ?Int16 {
        return resultSet.getInt16(index)
    }
    
    public override func getUInt16(index: Int64): ?UInt16 {
        return resultSet.getUInt16(index)
    }

    public override func getInt32(index: Int64): ?Int32 {
        return resultSet.getInt32(index)
    }

    public override func getUInt32(index: Int64): ?UInt32 {
        return resultSet.getUInt32(index)
    }

    public override func getInt64(index: Int64): ?Int64 {
        return resultSet.getInt64(index)
    }

    public override func getUInt64(index: Int64): ?UInt64 {
        return resultSet.getUInt64(index)
    }

    public override func getFloat16(index: Int64): ?Float16 {
        return resultSet.getFloat16(index)
    }

    public override func getFloat32(index: Int64): ?Float32 {
        return resultSet.getFloat32(index)
    }

    public override func getFloat64(index: Int64): ?Float64 {
        return resultSet.getFloat64(index)
    }

    public override func getBigInt(index: Int64): ?BigInt {
        return resultSet.getBigInt(index)
    }

    public override func getDecimal(index: Int64): ?Decimal {
        return resultSet.getDecimal(index)
    }

    public override func getDate(index: Int64): ?DateTime {
        return resultSet.getDate(index)
    }

    public override func getTime(index: Int64): ?DateTime {
        return resultSet.getTime(index)
    }

    public override func getDateTime(index: Int64): ?DateTime {
        return resultSet.getDateTime(index)
    }

    public override func getTimestamp(index: Int64): ?DateTime {
        return resultSet.getTimestamp(index)
    }

    public override func getInputStream(index: Int64): ?InputStream {
        return resultSet.getInputStream(index)
    }

    public override func getString(index: Int64): ?String {
        return resultSet.getString(index)
    }

    public override func getArray(index: Int64): ?Array<Byte> {
        return resultSet.getArray(index)
    }

    public override func getJsonValue(index: Int64): ?JsonValue {
        return resultSet.getJsonValue(index)
    }

    public override func metadata(index: Int64): ColumnDefinition {
        return columns[index - 1]
    }

}