/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc.impl

import std.collection.Map
import std.sync.*
import std.convert.*
import cjmd.jdbc.*
import cjmd.connection.*
import cjmd.result.*
import cjmd.protocol.*

public class ConnectionImpl <: Connection {
    
    
    private var _connection: MySqlConnection


    private var _options: Map<String, String>


    public ConnectionImpl(options: Map<String, String>){
        _options = options
        try {
             _connection = MySqlConnection.createAuthedConnection(options)
             applyOptions()
        }catch (e: ConnectFailedException) {
            throw SqlException(e.message)
        }
    }

    override public func getMetaData(): Map<String,String>{
        checkResourceAvailability()
        return _options
    }
    
    override public func prepareStatement(sql: String): Statement{
        checkResourceAvailability()
        checkEmptySql(sql)
        //return ClientPrepareStatement(this,sql)
        //return ServerPrepareStatement(this, sql)
        var prepareMode: String = _options.get(ConnectionOption.PrepareMode).getOrDefault({=>"auto"})
        if(prepareMode == "auto"){
            if(sql.size > 100 && sql.toAsciiLower().startsWith("select")){
                return ServerPrepareStatement(sql, this)
            }else{
                return ClientPrepareStatement(this,sql)
            }
        }else if(prepareMode == "server"){
            return ServerPrepareStatement(sql, this)
        }else if(prepareMode == "client"){
            return ClientPrepareStatement(this, sql)
        }else {
            throw SqlException("Unknow prepare mode: ${prepareMode} option: auto, server or client")
        }
    }

    override public func setAutoCommit(autoCommit: Bool): Unit {
        
    }

    override public func getAutoCommit(): Bool {
        return true
    }

    override public func setTransactionIsolation(level: IsolationLevel): Unit {

    }

    override public func getTransactionIsolation(): IsolationLevel {
        return Unsupported
    }

    override public func begin(): Unit {

    }

    override public func commit(): Unit {

    }

    override public func rollback(): Unit {

    }

    override public func setSavepoint(name: String): Unit {

    }

    override public func rollback(name: String): Unit {

    }

    override public func releaseSavepoint(name: String): Unit {

    }

    override public func setReadOnly(readOnly: Bool): Unit {

    }

    override public func isReadOnly(): Bool {
        return true
    }

    override public func close(){
        checkResourceAvailability()
        synchronized(getConnectionMutex()){
            _connection.close()
        }
    }
    
    override public func isClosed(): Bool{
        return _connection.isClosed()
    }

    //protected
    protected func getConnectionMutex(): ReentrantMutex{
        return _connection.mutex
    }

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

    protected func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        try {
            return _connection.executeUpdatePrepare(prepare, params)
        }catch (e: ResponseErrorException  | ParameterConvertException) {
            throw SqlException(e.message)
        }
    }

    protected func closePrepare(prepare: PrepareResult) {
        return _connection.closePrepare(prepare)
    }

    //private
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
        var queryTimeout = _options.get(ConnectionOption.QueryTimeout)
        if(!queryTimeout.isNone()){
            try {
                var timeout = Int64.parse(queryTimeout.getOrThrow())
                sendCommand("set session max_execution_time = ${timeout}")
            }catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("parse query_timeout failed")
            }
        }

        var updateTimeout = _options.get(ConnectionOption.UpdateTimeout)
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