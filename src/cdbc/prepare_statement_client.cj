/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
package mariadb.cdbc

import std.io.*
import std.time.*
import std.collection.*
import std.math.numeric.*
import std.database.sql.*

public class ClientPrepareStatement <: Statement {

    private let parameters: Array<Any>

    private let connection: ConnectionImpl

    private let originSql: String

    private let options: HashMap<String, String>

    private let parts: Array<String>

    private var closed: Bool

    private var cachedSql: ?String

    public ClientPrepareStatement(originSql: String, connection: ConnectionImpl) {
        this.connection = connection
        this.originSql = originSql
        this.closed = false
        this.options = HashMap<String, String>()
        this.parameters = Array<Any>(originSql.count("?"), repeat: Option<Any>.None)
        this.parts = originSql.split("?", removeEmpty: true)
        this.cachedSql = None
    }

    public override prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            throw UnsupportedException("get parameters info must set prepare.mode=server in connection")
        }
    }

    @Deprecated
    public override func query(_: Array<SqlDbType>): QueryResult {
        throw UnsupportedException("Deprecated method")
    }

    @Deprecated
    public override func update(_: Array<SqlDbType>): UpdateResult {
        throw UnsupportedException("Deprecated method")
    }

    public func set<T>(index: Int, value: T): Unit {
        checkResource()
        if(index <= 0) {
            throw IllegalArgumentException("The parameter index must be greater than 0")
        }
        func unwrap<T>(value: ?T) {
            if(let Some(v) <- value) {
                parameters[index - 1] = v
            }else {
                parameters[index - 1] = Option<Any>.None
            }
        }
        match (value) {
            case v: ?Bool => unwrap(v)
            case v: ?Int8 => unwrap(v)
            case v: ?UInt8 => unwrap(v)
            case v: ?Int16 => unwrap(v)
            case v: ?UInt16 => unwrap(v)
            case v: ?Int32 => unwrap(v)
            case v: ?UInt32 => unwrap(v)
            case v: ?Int64 => unwrap(v)
            case v: ?UInt64 => unwrap(v)
            case v: ?Float16 => unwrap(v)
            case v: ?Float32 => unwrap(v)
            case v: ?Float64 => unwrap(v)
            case v: ?Rune => unwrap(v)
            case v: ?String => unwrap(v)
            case v: ?DateTime => unwrap(v)
            case v: ?BigInt => unwrap(v)
            case v: ?Decimal => unwrap(v)
            case v: ?Array<Byte> => unwrap(v)
            case v: ?InputStream => unwrap(v)
            case _ => parameters[index - 1] = value
        }
        cachedSql = None
    }

    public func setNull(index: Int): Unit {
        checkResource()
        if(index <= 0) {
            throw IllegalArgumentException("The parameter index must be greater than 0")
        }
        parameters[index - 1] = Option<Any>.None
        cachedSql = None
    }

    public func update(): UpdateResult {
        checkResource()
        let executeableSql = getOrBuildSql()
        let result = connection.sendUpdate(executeableSql)
        var lastInsertId: Int64 = 0
        if (result.lastInsertId > 0) {
            lastInsertId += Int64(result.lastInsertId) + insertCount(originSql) - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public func query(): QueryResult {
        checkResource()
        let executeableSql = getOrBuildSql()
        return QueryResultImpl(connection.sendQuery(executeableSql))
    }

    public override func setOption(key: String, value: String): Unit {
        checkResource()
        options.add(key, value)
    }

    private func getOrBuildSql(): String {
        match (cachedSql) {
            case Some(s) => s
            case None =>
                let built = buildSql()
                cachedSql = built
                built
        }
    }

    private func buildSql(): String {
        let sqlBuilder = StringBuilder()
        for(i in 0..parts.size) {
            sqlBuilder.append(parts[i])
            if(i < parameters.size) {
                match (parameters[i]) {
                    case param: SqlParameter => sqlBuilder.append(param.asParameter())
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
        cachedSql = None
    }

    public override func isClosed(): Bool {
        return closed
    }

}
