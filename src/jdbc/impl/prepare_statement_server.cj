/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl


import std.time.DateTime
import std.sync.AtomicBool
import std.collection.ArrayList
import std.regex.Regex
import std.regex.Matcher
import mysqlclient4cj.jdbc.Date
import mysqlclient4cj.jdbc.Time
import mysqlclient4cj.jdbc.QueryResult
import mysqlclient4cj.jdbc.SqlException
import mysqlclient4cj.jdbc.UpdateResult
import mysqlclient4cj.result.PrepareResult
import mysqlclient4cj.protocol.nothing

public class ServerPrepareStatement <: AllocateStatement {

    private let id: UInt32

    private let prepareResult: PrepareResult

    private let connection: ConnectionImpl

    private let closed: AtomicBool

    public ServerPrepareStatement(originSql: String, connection: ConnectionImpl) {
        super(originSql)
        this.connection = connection
        this.prepareResult = connection.sendPrepare(originSql)
        this.id = prepareResult.id
        this.closed = AtomicBool(false)
    }

    public override func query(params: Array<Any>): QueryResult {
        checkResourceAvailability()
        for(i in 0..params.size){
            match(params[i]){
                case v: Date => params[i] = v.raw()
                case v: Time => params[i] = v.raw()
                case _ => nothing(0)
            }
        }
        let result = connection.executeQueryPrepare(prepareResult, params)
        return QueryResultImpl(result)
    }

    public override func update(params: Array<Any>): UpdateResult {
        checkResourceAvailability()
        for(i in 0..params.size){
            match(params[i]){
                case v: Date => params[i] = v.raw()
                case v: Time => params[i] = v.raw()
                case _ => nothing(0)
            }
        }
        let result = connection.executeUpdatePrepare(prepareResult, params)
        var lastInsertId: Int64 = 0
        if (result.lastInsertId > 0) {
            lastInsertId += Int64(result.lastInsertId) + getInsertCount() - 1
        }
        return UpdateResultImpl(Int64(result.effectRow), lastInsertId)
    }

    public override func query(): QueryResult {
        return query(params)
    }

    public override func update(): UpdateResult {
        return update(params)
    }

    public override func close() {
        checkResourceAvailability()
        connection.closePrepare(prepareResult.id)
        closed.store(true)
    }

    public override func isClosed(): Bool {
        return closed.load()
    }

    private func getInsertCount(): Int64 {
        let matcher = Matcher(Regex("\\((.*?)\\)"), originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw SqlException("The Statement has been closed")
        }
    }
}
