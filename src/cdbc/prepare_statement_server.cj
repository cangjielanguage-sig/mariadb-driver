/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */

package mysqlclient4cj.cdbc

import std.convert.*
import std.database.sql.*
import std.sync.*
import std.collection.*
import std.regex.*
import mysqlclient4cj.result.*

public class ServerPrepareStatement <: Statement {

    private var _id: UInt32

    private var _option: Map<String, String>

    private var _paramsInfo: Array<ColumnInfo>

    private var _prepareResult: PrepareResult

    private var _connection: ConnectionImpl

    private var _originSql: String

    private var _closed: AtomicBool

    public ServerPrepareStatement(originSql: String, connection: ConnectionImpl) {
        _connection = connection
        _prepareResult = _connection.sendPrepare(originSql)
        _option = HashMap<String, String>()
        _id = _prepareResult.id
        _originSql = originSql
        _closed = AtomicBool(false)
        _paramsInfo = []
        _paramsInfo = paramsInfo()
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return _paramsInfo
        }
    }

    public override func query(params: Array<SqlDbType>): QueryResult {
        var parameters = getParams(params)
        let result = match (_option.get("fetchSize")) {
            case None => 
                _connection.executeQueryPrepare(_prepareResult, parameters)
            case Some(v) => 
                let fetchSize = UInt32.parse(v)
                _connection.executeQueryPrepareWithCurosr(_prepareResult, parameters, fetchSize)
        }
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
        _connection.closePrepare(_id)
        _closed.store(true)
    }

    public override func isClosed(): Bool {
        return _closed.load()
    }

    private func getInsertCount(): Int64 {
        var matcher = Matcher(Regex("\\((.*?)\\)"), _originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }

    private func paramsInfo(): Array<ColumnInfo> {
        let defines = _prepareResult.paramDefinitions
        let size = defines.size
        let infos = ArrayList<ColumnInfo>(size)
        for(i in defines) {
            let nullable = i.hasFlag(NotNull)
            let info = ColumnInfoImpl(i.name, toSqlType(i.columnType, nullable), Int64(i.columnLength), Int64(i.columnLength), Int64(i.decimals), nullable)
            infos.append(info)
        }
        return infos.toArray()
    }
}
