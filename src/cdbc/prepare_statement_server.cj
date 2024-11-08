/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */

package mysqlclient4cj.cdbc

import std.database.sql.*
import std.convert.Parsable
import std.sync.AtomicBool
import std.collection.ArrayList
import std.collection.HashMap
import std.regex.Regex
import std.regex.Matcher
import mysqlclient4cj.result.PrepareResult
import mysqlclient4cj.protocol.ColumnFlag

public class ServerPrepareStatement <: Statement {

    private var id: UInt32

    private var options: HashMap<String, String>

    private var paramsInfo: Array<ColumnInfo> = []

    private var prepareResult: PrepareResult

    private var connection: ConnectionImpl

    private var originSql: String

    private var closed: AtomicBool

    public ServerPrepareStatement(originSql: String, connection: ConnectionImpl) {
        this.connection = connection
        this.prepareResult = connection.sendPrepare(originSql)
        this.options = HashMap<String, String>()
        this.id = prepareResult.id
        this.originSql = originSql
        this.closed = AtomicBool(false)
        this.paramsInfo = parseParamsInfo()
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return paramsInfo
        }
    }

    public override func query(params: Array<SqlDbType>): QueryResult {
        let parameters = getParams(params)
        let result = match (options.get("fetchSize")) {
            case None => 
                connection.executeQueryPrepare(prepareResult, parameters)
            case Some(v) => 
                let fetchSize = UInt32.parse(v)
                connection.executeQueryPrepareWithCurosr(prepareResult, parameters, fetchSize)
        }
        return QueryResultImpl(result)
    }

    public override func update(params: Array<SqlDbType>): UpdateResult {
        checkResourceAvailability()
        var parameters = getParams(params)
        var result = connection.executeUpdatePrepare(prepareResult, parameters)
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
        options.put(key, value)
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw SqlException("The Statement has been closed")
        }
    }

    public override func close() {
        checkResourceAvailability()
        connection.closePrepare(id)
        closed.store(true)
    }

    public override func isClosed(): Bool {
        return closed.load()
    }

    private func getInsertCount(): Int64 {
        var matcher = Matcher(Regex("\\((.*?)\\)"), originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }

    private func parseParamsInfo(): Array<ColumnInfo> {
        let defines = prepareResult.paramDefinitions
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
