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

import std.sync.*
import std.time.*
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
        let sqlBuilder = StringBuilder()
        let parts = originSql.split("?", removeEmpty: true)
        for(i in 0..parts.size) {
            sqlBuilder.append(parts[i])
            if(i < params.size) {
                match (params[i]) {
                    case param: Parameter =>sqlBuilder.append(param.asParameter())
                    case _ =>  throw UnsupportedException("an unsupported sql type")
                }
            }
        }
        return sqlBuilder.toString()
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
