/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.collection.*
import std.sync.*
import std.convert.*
import std.database.sql.Connection
import std.database.sql.ConnectionState
import std.database.sql.Transaction
import std.database.sql.Statement
import std.database.sql.QueryResult
import std.database.sql.UpdateResult
import std.database.sql.SqlException
import mysqlclient4cj.result.*
import mysqlclient4cj.protocol.ParameterConvertException
import mysqlclient4cj.connection.*

public class ConnectionImpl <: Connection{
    
    /*描述与数据源连接的当前状态*/
    private var _state: ConnectionState
    
    private var _connection: MySqlConnection

    private var _transaction: ?Transaction

    private var _options: Map<String, String>

    override public prop state: ConnectionState{
        get() {
            return _state
        }
    }

    public ConnectionImpl(options: Map<String, String>){
        _state = ConnectionState.Connecting
        _options = options
        _transaction = None
        try {
             _connection = MySqlConnectionFactory.createAuthedConnection(options)
             applyOptions()
        }catch (e: ConnectFailedException) {
            _state = ConnectionState.Broken
            throw e
        }
        _state = ConnectionState.Connected
    }

    /*返回连接到的数据源元数据*/
    override public func getMetaData(): Map<String,String>{
        checkResourceAvailability()
        return _options
    }
    
    /*通过传入的 sql 语句，返回一个预执行的 Statement 对象实例。*/
    override public func prepareStatement(sql: String): Statement{
        checkResourceAvailability()
        checkEmptySql(sql)
        var prepareMode: String = _options.get(Params.PrepareMode).getOrDefault({=> "client"})
        if (prepareMode == "server") {
            return ServerPrepareStatement(sql, this)
        } else if (prepareMode == "client") {
            return ClientPrepareStatement(sql, this)
        } else {
            throw SqlException("Unknow prepare mode: ${prepareMode} option: auto, server or client")
        }
    }

    /*创建事务对象*/
    override public func createTransaction(): Transaction{
        checkResourceAvailability()
        synchronized(getConnectionMutex()){
            if(_transaction.isNone()){
                _transaction = TransactionImpl(this)
            }
            return _transaction.getOrThrow()
        }
    }

    override public func close(){
        checkResourceAvailability()
        synchronized(getConnectionMutex()){
            _state = ConnectionState.Closed
            _connection.close()
        }
    }
    
    override public func isClosed(): Bool{
        return _connection.isClosed()
    }

    //protected---
    protected func sendCommand(sql: String) {
        try {
            return _connection.sendCommand(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendQuery(sql: String): ResultSet {
        try {
            return _connection.sendQuery(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendUpdate(sql: String): ChangeResult {
        try {
            return _connection.sendUpdate(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendPrepare(sql: String): PrepareResult {
        try {
            return _connection.sendPrepare(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func executeQueryPrepare(prepare: PrepareResult, params: Array<Any>): ResultSet {
        try {
            return _connection.executeQueryPrepare(prepare, params)
        }catch (e: ResponseErrorException | ParameterConvertException) {
            throw SqlException(e.message)
        }
    }

    protected func executeQueryPrepareWithCurosr(prepare: PrepareResult, params: Array<Any>, fetchSize: UInt32): ResultSet {
        try {
            return _connection.executeQueryPrepareWithCurosr(prepare, params, fetchSize)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        try {
            return _connection.executeUpdatePrepare(prepare, params)
        }catch (e: ResponseErrorException  | ParameterConvertException) {
            throw SqlException(e.message)
        }
    }

    protected func closePrepare(id: UInt32) {
        return _connection.closePrepare(id)
    }

    protected func getConnectionMutex(): ReentrantMutex{
        return _connection.mutex
    }

    //private---
    private func checkEmptySql(sql: String){
        if(sql.size == 0){
            throw SqlException("Empty SQL")
        }
    }
    
    private func checkResourceAvailability(){
        if(isClosed()){
            throw SqlException("The database Connection has been closed")
        }
    }

    private func applyOptions(){
        var queryTimeout = _options.get(Params.QueryTimeout)
        if(!queryTimeout.isNone()){
            try {
                var timeout = Int64.parse(queryTimeout.getOrThrow())
                sendCommand("set session max_execution_time = ${timeout}")
            }catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("parse query_timeout failed")
            }
        }

        var updateTimeout = _options.get(Params.UpdateTimeout)
        if(!updateTimeout.isNone()){
             try {
                var timeout = Int64.parse(updateTimeout.getOrThrow())
                sendCommand("set session lock_wait_timeout = ${timeout}")
             }catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("parse update_timeout failed")
             }
        }
    }
}