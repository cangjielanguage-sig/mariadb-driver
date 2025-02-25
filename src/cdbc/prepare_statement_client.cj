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
        let replacer = Matcher(Regex("?"), originSql)

        func withQuotation(value: String): String {
            let builder = StringBuilder()
            builder.append("'")
            for(i in value.toRuneArray()) {
                match (i) {
                    // case r'\u{0000}' => builder.append("\\0")
                    // case r'\n' => builder.append("\\n")
                    // case r'\r' => builder.append("\\r")
                    // case r'\u{001a}' => builder.append("\\Z")
                    case r'\'' => builder.append("\'\'")
                    case r'\\' => builder.append("\\\\")
                    case _ => builder.append(i)
                }
            }
            builder.append("'")
            return replacer.replace(builder.toString())
        }

        func withoutQuotation(value: String): String {
            return replacer.replace(value)
        }

        for (i in 0..params.size) {
            match (params[i]) {
                case v: SqlBool => 
                    withQuotation(v.value.toString())
                case v: SqlByte => 
                    withoutQuotation(v.value.toString())
                case v: SqlSmallInt => 
                    withoutQuotation(v.value.toString())
                case v: SqlInteger => 
                    withoutQuotation(v.value.toString())
                case v: SqlBigInt => 
                    withoutQuotation(v.value.toString())
                case v: SqlReal => 
                    withoutQuotation(v.value.toString())
                case v: SqlDouble => 
                    withoutQuotation(v.value.toString())
                case v: SqlDecimal => 
                    withQuotation(v.value.toString())
                case v: SqlChar => 
                    withQuotation(v.value.toString())
                case v: SqlVarchar => 
                    withQuotation(v.value.toString())
                case v: SqlClob => 
                    withoutQuotation(toArray(v.value).toHexStringWithPrefix())
                case v: SqlBlob => 
                    withoutQuotation(toArray(v.value).toHexStringWithPrefix())
                case v: SqlDate => 
                    withQuotation(v.value.toString(DateTimeFormat.of(DB_DATE_FORMAT)))
                case v: SqlTime => 
                    withQuotation(v.value.toString(DateTimeFormat.of(DB_TIME_FORMAT)))
                case v: SqlTimeTz => 
                    withQuotation(v.value.toString(DateTimeFormat.of(DB_TIME_FORMAT)))
                case v: SqlTimestamp => 
                    withQuotation(v.value.toString(DateTimeFormat.of(DB_DATE_TIME_FORMAT)))
                case v: SqlBinary => 
                    withoutQuotation(v.value.toHexStringWithPrefix())
                case v: SqlVarBinary => 
                    withoutQuotation(v.value.toHexStringWithPrefix())
                case v: SqlJson => 
                    withQuotation(v.value.toJsonString())
                case v: SqlNullableBool => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toString())
                    }
                case v: SqlNullableByte => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toString())
                    }
                case v: SqlNullableSmallInt => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toString())
                    }
                case v: SqlNullableInteger => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toString())
                    }
                case v: SqlNullableBigInt => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toString())
                    }
                case v: SqlNullableReal => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toString())
                    }
                case v: SqlNullableDouble => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toString())
                    }
                case v: SqlNullableDecimal => match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toString())
                    }
                case v: SqlNullableChar => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toString())
                    }
                case v: SqlNullableVarchar => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toString())
                    }
                case v: SqlNullableClob => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(toArray(s).toHexStringWithPrefix())
                    }
                case v: SqlNullableBlob => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(toArray(s).toHexStringWithPrefix())
                    }
                case v: SqlNullableDate => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toString(DateTimeFormat.of(DB_DATE_FORMAT)))
                    }
                case v: SqlNullableTime => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toString(DateTimeFormat.of(DB_TIME_FORMAT)))
                    }
                case v: SqlNullableTimeTz => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toString(DateTimeFormat.of(DB_TIME_FORMAT)))
                    }
                case v: SqlNullableTimestamp => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toString(DateTimeFormat.of(DB_DATE_TIME_FORMAT)))
                    }
                case v: SqlNullableBinary => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation(s.toHexStringWithPrefix())
                    }
                case v: SqlNullableVarBinary => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withoutQuotation( s.toHexStringWithPrefix())
                    }
                case v: SqlNullableJson => 
                    match (v.value) {
                        case None => withoutQuotation("NULL")
                        case Some(s) => withQuotation(s.toJsonString())
                    }
                case _ => 
                    throw UnsupportedException("An unsupported input type")
            }
        }
        return replacer.replace("?")
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
