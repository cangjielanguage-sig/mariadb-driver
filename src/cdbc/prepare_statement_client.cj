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

import std.collection.*
import std.database.sql.*

public class ClientPrepareStatement <: Statement {

    private let parameters: Array<Any>

    private let connection: ConnectionImpl

    private let originSql: String

    private let options: HashMap<String, String>

    private var closed: Bool

    public ClientPrepareStatement(originSql: String, connection: ConnectionImpl) {
        this.connection = connection
        this.originSql = originSql
        this.closed = false
        this.options = HashMap<String, String>()
        this.parameters = Array<Any>(originSql.count("?"), repeat: Option<Any>.None)
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            throw UnsupportedException("get parameters info must set prepare.mode=server in connection")
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
        let executeableSql = getExecuteableSql()
        let result = connection.sendUpdate(executeableSql)
        var lastInsertId: Int64 = 0
        if (result.lastInsertId > 0) {
            lastInsertId += Int64(result.lastInsertId) + insertCount(originSql) - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public func query(): QueryResult {
        checkResource()
        let executeableSql = getExecuteableSql()
        return QueryResultImpl(connection.sendQuery(executeableSql))
    }

    public override func setOption(key: String, value: String): Unit {
        checkResource()
        options.add(key, value)
    }

    private func getExecuteableSql(): String {
        let sqlBuilder = StringBuilder()
        let parts = originSql.split("?", removeEmpty: true)
        for(i in 0..parts.size) {
            sqlBuilder.append(parts[i])
            if(i < parameters.size) {
                match (parameters[i]) {
                    case param: SqlParameter =>sqlBuilder.append(param.asParameter())
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
        checkResource()
        closed = true
    }

    public override func isClosed(): Bool {
        return closed
    }

}
