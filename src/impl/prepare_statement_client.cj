/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.impl

import std.database.sql.*
import std.collection.*
import std.convert.*
import std.time.*
import std.io.*
import encoding.json.*
import encoding.hex.*
import cjmd.connection.*
import cjmd.result.*
import std.sync.*
import std.regex.*
import cjmd.protocol.*

public class ClientPrepareStatement <: Statement {

    private static const PLACEHOLDER: String = "?"

    private var _parameterColumnInfos: Array<ColumnInfo> = Array<ColumnInfo>()

    private var _connection: ConnectionImpl

    private var _originSql: String

    private var _option: Map<String, String>

    private var _closed: AtomicBool

    public ClientPrepareStatement(connection: ConnectionImpl, originSql: String) {
        _parameterColumnInfos = Array<ColumnInfo>()
        _connection = connection
        _originSql = originSql
        _closed = AtomicBool(false)
        _option = HashMap<String, String>()
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            checkResourceAvailability()
            return _parameterColumnInfos
        }
    }

    public override func close() {
        _closed.store(true)
    }

    public override func isClosed(): Bool {
        return _closed.load()
    }

    public override func query(params: Array<SqlDbType>): QueryResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        return QueryResultImpl(_connection.sendQuery(executeableSql))
    }

    public override func update(params: Array<SqlDbType>): UpdateResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        var result = _connection.sendUpdate(executeableSql)
        var lastInsertId: Int64 = 0
        if (result.firstInsertId > 0) {
            lastInsertId += Int64(result.firstInsertId) + getInsertCount() - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public override func setOption(key: String, value: String): Unit {
        checkResourceAvailability()
        _option.put(key, value)
    }

    private func getExecuteableSql(params: Array<SqlDbType>): String {
        if (params.size != _originSql.count("?")) {
            throw SqlException("The number of placeholders does not match the number of parameters")
        }
        var replacer = Matcher(Regex(PLACEHOLDER), _originSql)
        for (i in 0..params.size) {
            match (params[i]) {
                case v: SqlBool => setParamWithoutQuotation(replacer, v.value.toString())
                case v: SqlByte => setParamWithoutQuotation(replacer, v.value.toString())
                case v: SqlSmallInt => setParamWithoutQuotation(replacer, v.value.toString())
                case v: SqlInteger => setParamWithoutQuotation(replacer, v.value.toString())
                case v: SqlBigInt => setParamWithoutQuotation(replacer, v.value.toString())
                case v: SqlReal => setParamWithoutQuotation(replacer, v.value.toString())
                case v: SqlDouble => setParamWithoutQuotation(replacer, v.value.toString())
                case v: SqlDecimal => setParamWithQuotation(replacer, v.value.toString())
                case v: SqlChar => setParamWithQuotation(replacer, v.value.toString())
                case v: SqlVarchar => setParamWithQuotation(replacer, v.value.toString())
                case v: SqlClob => setParamWithoutQuotation(replacer, arrayToHexString(inputStreamToArray(v.value)))
                case v: SqlBlob => setParamWithoutQuotation(replacer, arrayToHexString(inputStreamToArray(v.value)))
                case v: SqlDate => setParamWithQuotation(replacer, v.value.toString(DB_DATE_FORMAT))
                case v: SqlTime => setParamWithQuotation(replacer, v.value.toString(DB_TIME_FORMAT))
                case v: SqlTimeTz => setParamWithQuotation(replacer, v.value.toString(DB_TIME_FORMAT))
                case v: SqlTimestamp => setParamWithQuotation(replacer,v.value.toString(DB_DATE_TIME_FORMAT))
                case v: SqlBinary => setParamWithoutQuotation(replacer, arrayToHexString(v.value))
                case v: SqlVarBinary => setParamWithoutQuotation(replacer, arrayToHexString(v.value))
                case v: SqlJson => setParamWithQuotation(replacer, v.value.toJsonString())

                case v: SqlNullableBool => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableByte => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableSmallInt => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableInteger => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableBigInt => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableReal => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableDouble => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableDecimal => if(v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                }else {
                    setParamWithQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableChar => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithQuotation(replacer, v.value.getOrThrow().toString())
                }
                case v: SqlNullableVarchar => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithQuotation(replacer, v.value.toString())
                }
                case v: SqlNullableClob => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, arrayToHexString(inputStreamToArray(v.value.getOrThrow())))
                }
                case v: SqlNullableBlob => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, arrayToHexString(inputStreamToArray(v.value.getOrThrow())))
                }
                case v: SqlNullableDate => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithQuotation(replacer, v.value.getOrThrow().toString(DB_DATE_FORMAT))
                }
                case v: SqlNullableTime => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithQuotation(replacer, v.value.getOrThrow().toString(DB_TIME_FORMAT))
                }
                case v: SqlNullableTimeTz => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithQuotation(replacer, v.value.getOrThrow().toString(DB_TIME_FORMAT))
                }
                case v: SqlNullableTimestamp => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithQuotation(replacer, v.value.getOrThrow().toString(DB_DATE_TIME_FORMAT))
                }
                case v: SqlNullableBinary => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, arrayToHexString(v.value.getOrThrow()))
                }
                case v: SqlNullableVarBinary => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithoutQuotation(replacer, arrayToHexString(v.value.getOrThrow()))
                }
                case v: SqlNullableJson => if (v.value.isNone()) {
                    setParamWithoutQuotation(replacer, "NULL")
                } else {
                    setParamWithQuotation(replacer, v.value.getOrThrow().toJsonString())
                }
                case _ => throw UnsupportedException("An unsupported input type")
            }
        }
        return replacer.replace(PLACEHOLDER)
    }

    private func setParamWithQuotation(replacer: Matcher, value: String): String {
        return replacer.replace("'${value}'")
    }

    private func setParamWithoutQuotation(replacer: Matcher, value: String): String {
        return replacer.replace(value)
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw SqlException("The Statement has been closed")
        }
    }

    private func getInsertCount(): Int64 {
        var matcher = Matcher(Regex("\\((.*?)\\)"), _originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }
}
