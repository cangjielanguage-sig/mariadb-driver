/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl

import std.collection.*
import std.convert.*
import std.time.*
import std.io.*
import std.sync.*
import std.regex.*
import std.math.numeric.{Decimal, BigInt}
import encoding.json.*
import encoding.hex.*
import mysqlclient4cj.connection.*
import mysqlclient4cj.result.*
import mysqlclient4cj.protocol.*
import mysqlclient4cj.jdbc.*

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
                    setParamWithoutQuotation(replacer, boolToInteger(v).toString())
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
                    setParamWithoutQuotation(replacer, arrayToHexString(inputStreamToArray(v)))
                case v: Array<Byte> => 
                    setParamWithoutQuotation(replacer, arrayToHexString(v))
                case v: JsonValue => 
                    setParamWithQuotation(replacer, v.toJsonString())
                case v: String => 
                    setParamWithQuotation(replacer, v)
                case v: ?Any => 
                    match (v) {
                        case None => setParamWithoutQuotation(replacer, "NULL")
                        case Some(v) => throw UnsupportedException("An unsupported input type: index ${i}")
                    }
                // case v: ?Bool => 
                //     match(v){
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, boolToInteger(v).toString())
                //     }
                // case v: ?Int8 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?UInt8 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?Int16 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?UInt16 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?Int32 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?UInt32 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?Int64 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?UInt64 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?Float16 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?Float32 => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?Float64=> 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, v.toString())
                //     }
                // case v: ?Decimal => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithQuotation(replacer, v.toString())
                //     }
                // case v: ?Date => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithQuotation(replacer, v.toString(DB_DATE_FORMAT))
                //     }
                // case v: ?Time => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithQuotation(replacer, v.toString(DB_TIME_FORMAT))
                //     }
                // case v: ?DateTime => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithQuotation(replacer,v.toString(DB_DATE_TIME_FORMAT))
                //     }
                // case v: ?InputStream => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, arrayToHexString(inputStreamToArray(v)))
                //     }
                // case v: ?String => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithQuotation(replacer, v)
                //     }
                // case v: ?Array<Byte> => 
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithoutQuotation(replacer, arrayToHexString(v))
                //     }
                // case v: ?JsonValue =>
                //     match (v) {
                //         case None => setParamWithoutQuotation(replacer, "NULL")
                //         case Some(v) => setParamWithQuotation(replacer, v.toString())
                //     }
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
