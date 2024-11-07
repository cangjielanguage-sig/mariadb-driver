/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl


import std.time.DateTime
import std.io.InputStream
import std.sync.AtomicBool
import std.collection.ArrayList
import std.regex.Regex
import std.regex.Matcher
import std.math.numeric.BigInt
import std.math.numeric.Decimal
import encoding.json.JsonValue
import mysqlclient4cj.jdbc.Date
import mysqlclient4cj.jdbc.Time
import mysqlclient4cj.jdbc.QueryResult
import mysqlclient4cj.jdbc.SqlException
import mysqlclient4cj.jdbc.UpdateResult
import mysqlclient4cj.protocol.toArray
import mysqlclient4cj.protocol.ToBool
import mysqlclient4cj.protocol.ToInteger
import mysqlclient4cj.protocol.ToHexString
import mysqlclient4cj.protocol.DB_DATE_FORMAT
import mysqlclient4cj.protocol.DB_TIME_FORMAT
import mysqlclient4cj.protocol.DB_DATE_TIME_FORMAT

public class ClientPrepareStatement <: AllocateStatement {

    private var _connection: ConnectionImpl

    private var _originSql: String

    private var _closed: AtomicBool

    public ClientPrepareStatement(originSql: String, connection: ConnectionImpl) {
        super(originSql)
        _connection = connection
        _originSql = originSql
        _closed = AtomicBool(false)
    }


    public override func close() {
        _closed.store(true)
    }

    public override func isClosed(): Bool {
        return _closed.load()
    }

    public override func query(params: Array<Any>): QueryResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        return QueryResultImpl(_connection.sendQuery(executeableSql))
    }

    public override func update(params: Array<Any>): UpdateResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        var result = _connection.sendUpdate(executeableSql)
        var lastInsertId: Int64 = 0
        if (result.firstInsertId > 0) {
            lastInsertId += Int64(result.firstInsertId) + getInsertCount() - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public override func query(): QueryResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        return QueryResultImpl(_connection.sendQuery(executeableSql))
    }

    public override func update(): UpdateResult {
        checkResourceAvailability()
        var executeableSql = getExecuteableSql(params)
        var result = _connection.sendUpdate(executeableSql)
        var lastInsertId: Int64 = 0
        if (result.firstInsertId > 0) {
            lastInsertId += Int64(result.firstInsertId) + getInsertCount() - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    private func getExecuteableSql(params: Array<Any>): String {
        if (params.size != _originSql.count("?")) {
            throw SqlException("The number of placeholders does not match the number of parameters")
        }
        var replacer = Matcher(Regex("?"), _originSql)
        for (i in 0..params.size) {
            match (params[i]) {
                case v: Bool =>
                    setParamWithoutQuotation(replacer, v.toInteger().toString())
                case v: Int8 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: UInt8 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: Int16 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: UInt16 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: Int32 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: UInt32 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: Int64 =>
                     setParamWithoutQuotation(replacer, v.toString())
                case v: UInt64 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: Float16 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: Float32 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: Float64 => 
                    setParamWithoutQuotation(replacer, v.toString())
                case v: BigInt =>
                    setParamWithQuotation(replacer, v.toString())
                case v: Decimal =>
                     setParamWithQuotation(replacer, v.toString())
                case v: Date => 
                    setParamWithQuotation(replacer, v.toString(DB_DATE_FORMAT))
                case v: Time => 
                    setParamWithQuotation(replacer, v.toString(DB_TIME_FORMAT))
                case v: DateTime => 
                    setParamWithQuotation(replacer,v.toString(DB_DATE_TIME_FORMAT))
                case v: InputStream => 
                    setParamWithoutQuotation(replacer, toArray(v).toHexStringWithPrefix())
                case v: Array<Byte> => 
                    setParamWithoutQuotation(replacer, v.toHexStringWithPrefix())
                case v: JsonValue => 
                    setParamWithQuotation(replacer, v.toJsonString())
                case v: String => 
                    setParamWithQuotation(replacer, v)
                case v: ?Any => 
                    match (v) {
                        case None => setParamWithoutQuotation(replacer, "NULL")
                        case Some(v) => throw UnsupportedException("An unsupported input type: index ${i}")
                    }
                case _ => throw UnsupportedException("An unsupported input type: index ${i}")
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
        var matcher = Matcher(Regex("\\((.*?)\\)"), _originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }
}
