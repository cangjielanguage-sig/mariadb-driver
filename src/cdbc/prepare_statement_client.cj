/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.cdbc

import std.sync.*
import std.time.*
import std.regex.*
import std.collection.*
import std.database.sql.*
import mysql.protocol.*

public class ClientPrepareStatement <: Statement {

    private let connection: ConnectionImpl

    private let originSql: String

    private let options: HashMap<String, String>

    private let closed: AtomicBool

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

    public override func query(params: Array<SqlDbType>): QueryResult {
        checkResource()
        let executeableSql = getExecuteableSql(params)
        return QueryResultImpl(connection.sendQuery(executeableSql))
    }

    public override func update(params: Array<SqlDbType>): UpdateResult {
        checkResource()
        let executeableSql = getExecuteableSql(params)
        let result = connection.sendUpdate(executeableSql)
        var lastInsertId: Int64 = 0
        if (result.lastInsertId > 0) {
            lastInsertId += Int64(result.lastInsertId) + insertCount(originSql) - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public override func setOption(key: String, value: String): Unit {
        checkResource()
        options.add(key, value)
    }

    private func getExecuteableSql(params: Array<SqlDbType>): String {
        if (params.size != originSql.count("?")) {
            throw SqlException("The number of placeholders does not match the number of parameters")
        }
        let regex = Regex("\\?")
        var sql = originSql
        for (i in 0..params.size) {
            sql = match (params[i]) {
                    case v: SqlBool => 
                        regex.replace(sql, "'" + v.value.toString() + "'")
                    case v: SqlByte => 
                        regex.replace(sql, v.value.toString())
                    case v: SqlSmallInt => 
                        regex.replace(sql, v.value.toString())
                    case v: SqlInteger => 
                        regex.replace(sql, v.value.toString())
                    case v: SqlBigInt => 
                        regex.replace(sql, v.value.toString())
                    case v: SqlReal => 
                        regex.replace(sql, v.value.toString())
                    case v: SqlDouble => 
                        regex.replace(sql, v.value.toString())
                    case v: SqlDecimal => 
                        regex.replace(sql, "'" + v.value.toString() + "'")
                    case v: SqlChar => 
                        regex.replace(sql, escapeString(v.value.toString()))
                    case v: SqlVarchar => 
                        regex.replace(sql, escapeString(v.value.toString()))
                    case v: SqlClob => 
                        regex.replace(sql, toArray(v.value).toHexStringWithPrefix())
                    case v: SqlBlob => 
                        regex.replace(sql, toArray(v.value).toHexStringWithPrefix())
                    case v: SqlDate => 
                        regex.replace(sql, "'" + v.value.format(DB_DATE_FORMAT) + "'")
                    case v: SqlTime => 
                        regex.replace(sql, "'" + v.value.format(DB_TIME_FORMAT) + "'")
                    case v: SqlTimeTz => 
                        regex.replace(sql, "'" + v.value.format(DB_TIME_FORMAT) + "'")
                    case v: SqlTimestamp => 
                        regex.replace(sql, "'" + v.value.format(DB_DATE_TIME_FORMAT) + "'")
                    case v: SqlBinary => 
                        regex.replace(sql, v.value.toHexStringWithPrefix())
                    case v: SqlVarBinary => 
                        regex.replace(sql, v.value.toHexStringWithPrefix())
                    case v: SqlJson => 
                        regex.replace(sql, escapeString(v.value.toString()))
                    case v: SqlNullableBool => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, "'" + s.toString() + "'")
                        }
                    case v: SqlNullableByte => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toString())
                        }
                    case v: SqlNullableSmallInt => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toString())
                        }
                    case v: SqlNullableInteger => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toString())
                        }
                    case v: SqlNullableBigInt => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toString())
                        }
                    case v: SqlNullableReal => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toString())
                        }
                    case v: SqlNullableDouble => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toString())
                        }
                    case v: SqlNullableDecimal => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, "'" + s.toString() + "'")
                        }
                    case v: SqlNullableChar => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, escapeString(s.toString()))
                        }
                    case v: SqlNullableVarchar => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, escapeString(s.toString()))
                        }
                    case v: SqlNullableClob => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, toArray(s).toHexStringWithPrefix())
                        }
                    case v: SqlNullableBlob => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, toArray(s).toHexStringWithPrefix())
                        }
                    case v: SqlNullableDate => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, "'" + s.format(DB_DATE_FORMAT) + "'")
                        }
                    case v: SqlNullableTime => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, "'" + s.format(DB_TIME_FORMAT) + "'")
                        }
                    case v: SqlNullableTimeTz => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, "'" + s.format(DB_TIME_FORMAT) + "'")
                    }
                    case v: SqlNullableTimestamp => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, "'" + s.format(DB_DATE_TIME_FORMAT) + "'")
                        }
                    case v: SqlNullableBinary => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toHexStringWithPrefix())
                        }
                    case v: SqlNullableVarBinary => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, s.toHexStringWithPrefix())
                        }
                    case v: SqlNullableJson => 
                        match (v.value) {
                            case None => regex.replace(sql, "NULL")
                            case Some(s) => regex.replace(sql, escapeString(s.toString()))
                        }
                    case _ => 
                        throw UnsupportedException("An unsupported input type")
            }
        }
        return sql
    }

    private func checkResource() {
        if (isClosed()) {
            throw SqlException("The Statement has been closed")
        }
    }

    public override func close() {
        closed.store(true)
    }

    public override func isClosed(): Bool {
        return closed.load()
    }

}
