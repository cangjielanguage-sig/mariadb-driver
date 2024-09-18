/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */

package cjmd.cdbc

import std.database.sql.*
import std.sync.*
import std.collection.*
import cjmd.result.*
import std.regex.*

public class ServerPrepareStatement <: Statement {

    private var _id: UInt32

    private var _option: Map<String, String>

    private var _parameterColumnInfos: Array<ColumnInfo>

    private var _prepareResult: PrepareResult

    private var _connection: ConnectionImpl

    private var _originSql: String

    private var _closed: AtomicBool

    public ServerPrepareStatement(connection: ConnectionImpl, originSql: String) {
        _connection = connection
        _prepareResult = _connection.sendPrepare(originSql)
        _option = HashMap<String, String>()
        _id = _prepareResult.id
        _originSql = originSql
        _parameterColumnInfos = []
        _closed = AtomicBool(false)
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return _parameterColumnInfos
        }
    }

    public override func query(params: Array<SqlDbType>): QueryResult {
        var parameters = getParams(params)
        var result = _connection.executeQueryPrepare(_prepareResult, parameters)
        return QueryResultImpl(result)
    }

    public override func update(params: Array<SqlDbType>): UpdateResult {
        checkResourceAvailability()
        var parameters = getParams(params)
        var result = _connection.executeUpdatePrepare(_prepareResult, parameters)
        var lastInsertId: Int64 = 0
        if (result.firstInsertId > 0) {
            lastInsertId += Int64(result.firstInsertId) + getInsertCount() - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    private func getParams(params: Array<SqlDbType>): Array<Any> {
        var parameters = ArrayList<Any>()
        for (i in 0..params.size) {
            match (params[i]) {
                case v: SqlBool => parameters.append(v.value)
                case v: SqlByte => parameters.append(v.value)
                case v: SqlSmallInt => parameters.append(v.value)
                case v: SqlInteger => parameters.append(v.value)
                case v: SqlBigInt => parameters.append(v.value)
                case v: SqlReal => parameters.append(v.value)
                case v: SqlDouble => parameters.append(v.value)
                case v: SqlDecimal => parameters.append(v.value)
                case v: SqlChar => parameters.append(v.value)
                case v: SqlVarchar => parameters.append(v.value)
                case v: SqlClob => parameters.append(v.value)
                case v: SqlBlob => parameters.append(v.value)
                case v: SqlDate => parameters.append(v.value)
                case v: SqlTime => parameters.append(v.value)
                case v: SqlTimeTz => parameters.append(v.value)
                case v: SqlTimestamp => parameters.append(v.value)
                case v: SqlBinary => parameters.append(v.value)
                case v: SqlVarBinary => parameters.append(v.value)
                case v: SqlJson => parameters.append(v.value)
                case v: SqlNullableBool => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableByte => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableSmallInt => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableInteger => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableBigInt => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableReal => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableDouble => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableDecimal => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                }else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableChar => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableVarchar => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableClob => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableBlob => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableDate => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableTime => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableTimeTz => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableTimestamp => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableBinary => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableVarBinary => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case v: SqlNullableJson => if (v.value.isNone()) {
                    parameters.append(Option<Any>.None)
                } else {
                    parameters.append(v.value.getOrThrow())
                }
                case _ => throw UnsupportedException("An unsupported input type")
            }
        }
        return parameters.toArray()
    }

    public override func setOption(key: String, value: String): Unit {
        checkResourceAvailability()
        _option.put(key, value)
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw SqlException("The Statement has been closed")
        }
    }

    public override func close() {
        checkResourceAvailability()
        _connection.closePrepare(_prepareResult)
        _closed.store(true)
    }

    public override func isClosed(): Bool {
        return _closed.load()
    }

    private func getInsertCount(): Int64 {
        var matcher = Matcher(Regex("\\((.*?)\\)"), _originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }
}
