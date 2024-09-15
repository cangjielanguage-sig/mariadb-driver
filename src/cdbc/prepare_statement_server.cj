/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */

package cjmd.cdbc
import cdbc.*
import std.sync.*
import std.collection.*
import std.regex.*
import std.database.sql.SqlException
import cjmd.protocol.nothingTodo
import cjmd.result.*

public class ServerPrepareStatement <: AllocateStatement {

    private var _id: UInt32

    private var _prepareResult: PrepareResult

    private var _connection: ConnectionImpl

    private var _closed: AtomicBool

    public ServerPrepareStatement(originSql: String, connection: ConnectionImpl) {
        super(originSql)
        _connection = connection
        _prepareResult = _connection.sendPrepare(originSql)
        _id = _prepareResult.id
        _closed = AtomicBool(false)
    }


    public override func query(params: Array<Any>): QueryResult {
        checkResourceAvailability()
        for(i in 0..params.size){
            match(i){
                case v: Date => params[i] = v.dateTime
                case v: Time => params[i] = v.dateTime
                case _ => nothingTodo(0)
            }
        }
        var result = _connection.executeQueryPrepare(_prepareResult, params)
        return QueryResultImpl(result)
    }

    public override func update(params: Array<Any>): UpdateResult {
        checkResourceAvailability()
        for(i in 0..params.size){
            match(params[i]){
                case v: Date => params[i] = v.dateTime
                case v: Time => params[i] = v.dateTime
                case _ => nothingTodo(0)
            }
        }
        var result = _connection.executeUpdatePrepare(_prepareResult, params)
        var lastInsertId: Int64 = 0
        if (result.firstInsertId > 0) {
            lastInsertId += Int64(result.firstInsertId) + getInsertCount() - 1
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
        _connection.closePrepare(_prepareResult)
        _closed.store(true)
    }

    public override func isClosed(): Bool {
        return _closed.load()
    }

    private func getInsertCount(): Int64 {
        var matcher = Matcher(Regex("\\((.*?)\\)"), originSql.split("values")[1])
        return matcher.findAll().getOrThrow().size
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw SqlException("The Statement has been closed")
        }
    }
}
