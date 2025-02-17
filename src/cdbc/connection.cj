/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.cdbc

import std.sync.*
import std.convert.*
import std.collection.*
import std.database.sql.*
import mysql.result.*
import mysql.protocol.*
import mysql.connection.*

public class ConnectionImpl <: Connection {
    
    private var currentState: ConnectionState
    
    private var connection: MySqlConnection

    private var transaction: Transaction

    private var options: Map<String, String>

    override public prop state: ConnectionState {
        get() {
            return currentState
        }
    }

    public ConnectionImpl(options: Map<String, String>) {
        this.currentState = ConnectionState.Connecting
        this.options = options
        try {
             this.connection = MySqlConnectionFactory.createAuthedConnection(options)
        }catch (e: ConnectFailedException) {
            currentState = ConnectionState.Broken
            throw e
        }
        this.transaction = TransactionImpl(connection.createTransaction())
        this.currentState = ConnectionState.Connected
        applyOptions()
    }

    override public func getMetaData(): Map<String,String> {
        checkResource()
        return options
    }
    
    override public func prepareStatement(sql: String): Statement {
        checkResource()
        checkEmptySql(sql)
        let prepareMode = options.get(Params.PrepareMode) ?? "client"
        if (prepareMode == "server") {
            ServerPrepareStatement(sql, this)
        } else if (prepareMode == "client") {
            return ClientPrepareStatement(sql, this)
        } else {
            throw SqlException("Unknow prepare mode: ${prepareMode} option: server or client")
        }
    }

    override public func createTransaction(): Transaction {
        checkResource()
        return transaction
    }

    override public func close() {
        checkResource()
        synchronized(getConnectionMutex()) {
            currentState = ConnectionState.Closed
            connection.close()
        }
    }
    
    override public func isClosed(): Bool {
        return connection.isClosed()
    }

    protected func sendCommand(sql: String) {
        try {
            return connection.sendCommand(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendQuery(sql: String): ResultSet {
        try {
            return connection.sendQuery(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendUpdate(sql: String): ChangeResult {
        try {
            return connection.sendUpdate(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendPrepare(sql: String): PrepareResult {
        try {
            return connection.sendPrepare(sql)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func executeQueryPrepare(prepare: PrepareResult, params: Array<Any>): ResultSet {
        try {
            return connection.executeQueryPrepare(prepare, params)
        }catch (e: ResponseErrorException | ParameterConvertException) {
            throw SqlException(e.message)
        }
    }

    protected func executeQueryPrepareWithCurosr(prepare: PrepareResult, params: Array<Any>, fetchSize: UInt32): ResultSet {
        try {
            return connection.executeQueryPrepareWithCurosr(prepare, params, fetchSize)
        }catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        try {
            return connection.executeUpdatePrepare(prepare, params)
        }catch (e: ResponseErrorException  | ParameterConvertException) {
            throw SqlException(e.message)
        }
    }

    protected func closePrepare(id: UInt32) {
        return connection.closePrepare(id)
    }

    protected func getConnectionMutex(): ReentrantMutex {
        return connection.mutex
    }

    private func checkEmptySql(sql: String) {
        if(sql.size == 0){
            throw SqlException("Empty SQL")
        }
    }
    
    private func checkResource() {
        if(isClosed()){
            throw SqlException("The database Connection has been closed")
        }
    }

    private func applyOptions() {
        let queryTimeout = options.get(Params.QueryTimeout)
        if(let Some(v) <- queryTimeout) {
            try {
                var timeout = Int64.parse(v)
                sendCommand("set session max_execution_time = ${timeout}")
            }catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("parse query_timeout failed")
            }
        }
        let updateTimeout = options.get(Params.UpdateTimeout)
        if(let Some(v) <- updateTimeout) {
             try {
                var timeout = Int64.parse(updateTimeout.getOrThrow())
                sendCommand("set session lock_wait_timeout = ${timeout}")
             }catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("parse update_timeout failed")
             }
        }
    }
}