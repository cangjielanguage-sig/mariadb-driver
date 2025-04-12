/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */

package mysql.cdbc

import std.sync.*
import std.convert.*
import std.collection.*
import std.database.sql.*
import mysql.result.*

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
            checkResource()
            return paramsInfo
        }
    }

    public override func query(params: Array<SqlDbType>): QueryResult {
        checkResource()
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
        let parameters = Array<Any>(params.size, repeat: 0)
        for (i in 0..params.size) {
            match (params[i]) {
                case param: Parameter => 
                    parameters[i] = param.unbox()
                case _ => throw UnsupportedException("an unsupported sql type")
            }
        }
        return parameters
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
