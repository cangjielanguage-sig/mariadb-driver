/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.*
import std.collection.HashMap
import std.sync.AtomicBool
import std.regex.Regex
import std.regex.Matcher
import mysqlclient4cj.protocol.toArray
import mysqlclient4cj.protocol.ToHexString
import mysqlclient4cj.protocol.DB_DATE_FORMAT
import mysqlclient4cj.protocol.DB_TIME_FORMAT
import mysqlclient4cj.protocol.DB_DATE_TIME_FORMAT

public class ClientPrepareStatement <: Statement {

    private var connection: ConnectionImpl

    private var originSql: String

    private var options: HashMap<String, String>

    private var closed: AtomicBool

    public ClientPrepareStatement(originSql: String, connection: ConnectionImpl) {
        this.connection = connection
        this.originSql = originSql
        this.closed = AtomicBool(false)
        this.options = HashMap<String, String>()
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            throw UnsupportedException("get parameters info must set prepare.mode=server in connection")
        }
    }

    public override func close() {
        closed.store(true)
    }

    public override func isClosed(): Bool {
        return closed.load()
    }

    public override func query(params: Array<SqlDbType>): QueryResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        return QueryResultImpl(connection.sendQuery(executeableSql))
    }

    public override func update(params: Array<SqlDbType>): UpdateResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        var result = connection.sendUpdate(executeableSql)
        var lastInsertId: Int64 = 0
        if (result.firstInsertId > 0) {
            lastInsertId += Int64(result.firstInsertId) + getInsertCount() - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public override func setOption(key: String, value: String): Unit {
        checkResourceAvailability()
        options.put(key, value)
    }

    private func getExecuteableSql(params: Array<SqlDbType>): String {
        if (params.size != originSql.count("?")) {
            throw SqlException("The number of placeholders does not match the number of parameters")
        }
        var replacer = Matcher(Regex("?"), originSql)
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
                case v: SqlClob => setParamWithoutQuotation(replacer, toArray(v.value).toHexStringWithPrefix())
                case v: SqlBlob => setParamWithoutQuotation(replacer, toArray(v.value).toHexStringWithPrefix())
                case v: SqlDate => setParamWithQuotation(replacer, v.value.toString(DB_DATE_FORMAT))
                case v: SqlTime => setParamWithQuotation(replacer, v.value.toString(DB_TIME_FORMAT))
                case v: SqlTimeTz => setParamWithQuotation(replacer, v.value.toString(DB_TIME_FORMAT))
                case v: SqlTimestamp => setParamWithQuotation(replacer, v.value.toString(DB_DATE_TIME_FORMAT))
                case v: SqlBinary => setParamWithoutQuotation(replacer, v.value.toHexStringWithPrefix())
                case v: SqlVarBinary => setParamWithoutQuotation(replacer, v.value.toHexStringWithPrefix())
                case v: SqlJson => setParamWithQuotation(replacer, v.value.toJsonString())

                case v: SqlNullableBool => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toString())
                }
                case v: SqlNullableByte => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toString())
                }
                case v: SqlNullableSmallInt => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toString())
                }
                case v: SqlNullableInteger => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toString())
                }
                case v: SqlNullableBigInt => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toString())
                }
                case v: SqlNullableReal => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toString())
                }
                case v: SqlNullableDouble => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toString())
                }
                case v: SqlNullableDecimal => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toString())
                }
                case v: SqlNullableChar => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toString())
                }
                case v: SqlNullableVarchar => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toString())
                }
                case v: SqlNullableClob => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, toArray(s).toHexStringWithPrefix())
                }
                case v: SqlNullableBlob => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, toArray(s).toHexStringWithPrefix())
                }
                case v: SqlNullableDate => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toString(DB_DATE_FORMAT))
                }
                case v: SqlNullableTime => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toString(DB_TIME_FORMAT))
                }
                case v: SqlNullableTimeTz => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toString(DB_TIME_FORMAT))
                }
                case v: SqlNullableTimestamp => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toString(DB_DATE_TIME_FORMAT))
                }
                case v: SqlNullableBinary => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toHexStringWithPrefix())
                }
                case v: SqlNullableVarBinary => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithoutQuotation(replacer, s.toHexStringWithPrefix())
                }
                case v: SqlNullableJson => match (v.value) {
                    case None => setParamWithoutQuotation(replacer, "NULL")
                    case Some(s) => setParamWithQuotation(replacer, s.toJsonString())
                }
                case _ => throw UnsupportedException("An unsupported input type")
            }
        }
        return replacer.replace("?")
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
        var matcher = Matcher(Regex("\\((.*?)\\)"), originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }
}
