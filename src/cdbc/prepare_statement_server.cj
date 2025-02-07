/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */

package mysql.cdbc

import std.sync.*
import std.regex.*
import std.convert.*
import std.collection.*
import std.database.sql.*
import mysql.result.*
import mysql.protocol.*

public class ServerPrepareStatement <: Statement {

    private let id: UInt32

    private let options: HashMap<String, String>

    private let paramsInfo: Array<ColumnInfo>

    private let prepareResult: PrepareResult

    private let connection: ConnectionImpl

    private let originSql: String

    private let closed: AtomicBool

    public ServerPrepareStatement(originSql: String, connection: ConnectionImpl) {
        this.connection = connection
        this.prepareResult = connection.sendPrepare(originSql)
        this.options = HashMap<String, String>()
        this.id = prepareResult.id
        this.originSql = originSql
        this.closed = AtomicBool(false)
        let array = ArrayList<ColumnInfo>()
        for(i in prepareResult.columns) {
            array.add(ColumnInfoImpl(i))
        }
        this.paramsInfo = array.toArray()
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return paramsInfo
        }
    }

    public override func query(params: Array<SqlDbType>): QueryResult {
        let parameters = getBasicValues(params)
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
        checkResource()
        let parameters = getBasicValues(params)
        let result = connection.executeUpdatePrepare(prepareResult, parameters)
        var lastInsertId: Int64 = 0
        if (result.lastInsertId > 0) {
            lastInsertId += Int64(result.lastInsertId) + insertCount(originSql) - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    private func getBasicValues(params: Array<SqlDbType>): Array<Any> {
        let parameters = ArrayList<Any>()
        for (i in 0..params.size) {
            match (params[i]) {
                case v: SqlBool => 
                    parameters.add(v.value)
                case v: SqlByte => 
                    parameters.add(v.value)
                case v: SqlSmallInt => 
                    parameters.add(v.value)
                case v: SqlInteger => 
                    parameters.add(v.value)
                case v: SqlBigInt => 
                    parameters.add(v.value)
                case v: SqlReal => 
                    parameters.add(v.value)
                case v: SqlDouble => 
                    parameters.add(v.value)
                case v: SqlDecimal => 
                    parameters.add(v.value)
                case v: SqlChar => 
                    parameters.add(v.value)
                case v: SqlVarchar => 
                    parameters.add(v.value)
                case v: SqlClob => 
                    parameters.add(v.value)
                case v: SqlBlob => 
                    parameters.add(v.value)
                case v: SqlDate => 
                    parameters.add(v.value)
                case v: SqlTime => 
                    parameters.add(v.value)
                case v: SqlTimeTz => 
                    parameters.add(v.value)
                case v: SqlTimestamp => 
                    parameters.add(v.value)
                case v: SqlBinary => 
                    parameters.add(v.value)
                case v: SqlVarBinary => 
                    parameters.add(v.value)
                case v: SqlJson => 
                    parameters.add(v.value)
                case v: SqlNullableBool => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableByte => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableSmallInt => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableInteger => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableBigInt => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableReal => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableDouble => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableDecimal => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableChar => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableVarchar => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableClob => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableBlob => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableDate => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableTime => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableTimeTz => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableTimestamp => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableBinary => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableVarBinary => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case v: SqlNullableJson => 
                    match (v.value) {
                        case None => parameters.add(Option<Any>.None)
                        case Some(s) => parameters.add(s)
                    }
                case _ => throw UnsupportedException("An unsupported input type")
            }
        }
        return parameters.toArray()
    }

    public override func setOption(key: String, value: String): Unit {
        checkResource()
        options.add(key, value)
    }

    private func checkResource() {
        if (isClosed()) {
            throw SqlException("The Statement has been closed")
        }
    }

    public override func close() {
        checkResource()
        connection.closePrepare(id)
        closed.store(true)
    }

    public override func isClosed(): Bool {
        return closed.load()
    }
    
}
