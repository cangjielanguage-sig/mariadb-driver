/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package mysql.cdbc

import std.convert.*
import std.collection.*
import std.database.sql.*
import mysql.result.*

public class ServerPrepareStatement <: Statement {

    private let parameters: Array<Any>

    private let id: UInt32

    private let options: HashMap<String, String>

    private let paramsInfo: Array<ColumnInfo>

    private let prepareResult: PrepareResult

    private let connection: ConnectionImpl

    private let originSql: String

    private var closed: Bool

    public init(originSql: String, connection: ConnectionImpl) {
        this.connection = connection
        this.prepareResult = connection.sendPrepare(originSql)
        for(i in prepareResult.params) {
            println(i.columnType)
        }
        this.options = HashMap<String, String>()
        this.id = prepareResult.id
        this.originSql = originSql
        this.closed = false
        let array = ArrayList<ColumnInfo>()
        for(i in prepareResult.columns) {
            array.add(ColumnInfoImpl(i))
        }
        this.paramsInfo = array.toArray()
        this.parameters = Array<Any>(originSql.count("?"), repeat: Option<Any>.None)
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            checkResource()
            return paramsInfo
        }
    }

    @Deprecated
    public override func query(params: Array<SqlDbType>): QueryResult {
        throw UnsupportedException("Deprecated method")
    }

    @Deprecated
    public override func update(params: Array<SqlDbType>): UpdateResult {
        throw UnsupportedException("Deprecated method")
    }

    public func set<T>(index: Int, value: T): Unit {
        parameters[index] = value
    }

    public func setNull(index: Int): Unit {
        parameters[index] = Option<Any>.None
    }

    public func update(): UpdateResult {
        checkResource()
        let result = connection.executeUpdatePrepare(prepareResult, parameters)
        var lastInsertId: Int64 = 0
        if (result.lastInsertId > 0) {
            lastInsertId += Int64(result.lastInsertId) + insertCount(originSql) - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public func query(): QueryResult {
        checkResource()
        let result = match (options.get("fetchSize")) {
            case None => 
                connection.executeQueryPrepare(prepareResult, parameters)
            case Some(v) => 
                let fetchSize = UInt32.parse(v)
                connection.executeQueryPrepareWithCurosr(prepareResult, parameters, fetchSize)
        }
        return QueryResultImpl(result)
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
        closed = true
    }

    public override func isClosed(): Bool {
        return closed
    }
    
}
