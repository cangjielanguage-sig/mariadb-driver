/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl

import std.collection.Map
import std.sync.ReentrantMutex
import std.convert.Parsable
import mysqlclient4cj.jdbc.Statement
import mysqlclient4cj.jdbc.Connection
import mysqlclient4cj.jdbc.SqlException
import mysqlclient4cj.jdbc.IsolationLevel
import mysqlclient4cj.result.ResultSet
import mysqlclient4cj.result.ChangeResult
import mysqlclient4cj.result.PrepareResult
import mysqlclient4cj.connection.Params
import mysqlclient4cj.connection.MySqlConnection
import mysqlclient4cj.connection.MySqlTransaction
import mysqlclient4cj.connection.ResponseErrorException
import mysqlclient4cj.connection.MySqlConnectionFactory
import mysqlclient4cj.connection.ConnectFailedException
import mysqlclient4cj.protocol.ParameterConvertException

public class ConnectionImpl <: Connection {

    private static const SET_SCHEMA = "USE"

    private static const GET_SCHEMA = "SELECT DATABASE()"

    private let connection: MySqlConnection

    private let transaction: MySqlTransaction 

    private let options: Map<String, String>

    public ConnectionImpl(options: Map<String, String>) {
        this.options = options
        try {
            this.connection = MySqlConnectionFactory.createAuthedConnection(options)
            this.transaction = connection.createTransaction()
            applyOptions()
        } catch (e: ConnectFailedException) {
            throw SqlException(e.message)
        }
    }

    public override func getMetaData(): Map<String, String> {
        checkResourceAvailability()
        return options
    }

    public override func prepareStatement(sql: String): Statement {
        checkResourceAvailability()
        checkEmptySql(sql)
        let prepareMode = options.get(Params.PrepareMode).getOrDefault({=> "client"})
        if (prepareMode == "server") {
            return ServerPrepareStatement(sql, this)
        } else if (prepareMode == "client") {
            return ClientPrepareStatement(sql, this)
        } else {
            throw SqlException("Unknow prepare mode: ${prepareMode} option: server or client")
        }
    }

    public override func getAutoCommit(): Bool {
        checkResourceAvailability()
        return transaction.getAutoCommit()
    }

    public override func setAutoCommit(autoCommit: Bool): Unit {
        checkResourceAvailability()
        return transaction.setAutoCommit(autoCommit)
    }

    public override func getTransactionIsolation(): IsolationLevel {
        match (transaction.getTransactionIsolation()) {
            case "READ-UNCOMMITTED" => return ReadUncommitted
            case "READ-COMMITTED" => return ReadCommitted
            case "REPEATABLE-READ" => return RepeatableRead
            case "SERIALIZABLE" => return Serializable
            case other => throw IllegalArgumentException("Unkonw isolation level: ${other}")
        } 
    }

    public override func setTransactionIsolation(level: IsolationLevel): Unit {
        checkResourceAvailability()
        match (level) {
            case ReadUncommitted => transaction.setTransactionIsolation("READ-UNCOMMITTED")
            case ReadCommitted => transaction.setTransactionIsolation("READ-COMMITTED")
            case RepeatableRead => transaction.setTransactionIsolation("REPEATABLE-READ")
            case Serializable => transaction.setTransactionIsolation("SERIALIZABLE")
            case Unsupported => transaction.setTransactionIsolation("REPEATABLE-READ")
        }
    }

    public override func begin(): Unit {
        checkResourceAvailability()
        transaction.begin()
    }

    public override func commit(): Unit {
        checkResourceAvailability()
        transaction.commit()
    }

    public override func rollback(): Unit {
        checkResourceAvailability()
        transaction.rollback()
    }

    public override func setSavepoint(name: String): Unit {
        checkResourceAvailability()
        transaction.setSavepoint(name)
    }

    public override func rollback(name: String): Unit {
        checkResourceAvailability()
        transaction.rollback(name)
    }

    public override func releaseSavepoint(name: String): Unit {
        checkResourceAvailability()
        transaction.releaseSavepoint(name)
    }

    public override func setReadOnly(readOnly: Bool): Unit {
        checkResourceAvailability()
        transaction.setReadOnly(readOnly)
    }

    public override func isReadOnly(): Bool {
        checkResourceAvailability()
        return transaction.isReadOnly()
    }

    public override func close() {
        checkResourceAvailability()
        connection.close()
    }

    public override func isClosed(): Bool {
        return connection.isClosed()
    }

    public func setSchema(schema: String): Unit {
        checkResourceAvailability()
        sendCommand("${SET_SCHEMA} ${schema}")
    }

    public func getSchema(): String {
        checkResourceAvailability()
        var result = connection.sendQuery(GET_SCHEMA)
        if (!result.next() || result.rowSize != 1 || result.columnSize != 1) {
            throw SqlException("Query the current database failed")
        }
        return result.getString(1).getOrThrow()
    }

    //protected
    protected func getConnectionMutex(): ReentrantMutex {
        return connection.mutex
    }

    protected func sendCommand(sql: String) {
        try {
            return connection.sendCommand(sql)
        } catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendQuery(sql: String): ResultSet {
        try {
            return connection.sendQuery(sql)
        } catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendUpdate(sql: String): ChangeResult {
        try {
            return connection.sendUpdate(sql)
        } catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func sendPrepare(sql: String): PrepareResult {
        try {
            return connection.sendPrepare(sql)
        } catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func executeQueryPrepare(prepare: PrepareResult, params: Array<Any>): ResultSet {
        try {
            return connection.executeQueryPrepare(prepare, params)
        } catch (e: ResponseErrorException | ParameterConvertException) {
            throw SqlException(e.message)
        }
    }

    protected func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        try {
            return connection.executeUpdatePrepare(prepare, params)
        } catch (e: ResponseErrorException | ParameterConvertException) {
            throw SqlException(e.message)
        }
    }

    protected func closePrepare(id: UInt32) {
        return connection.closePrepare(id)
    }

    //private
    private func checkEmptySql(sql: String) {
        if (sql.size == 0) {
            throw SqlException("Empty SQL")
        }
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw SqlException("The database Connection has been closed")
        }
    }

    private func applyOptions() {
        var queryTimeout = options.get(Params.QueryTimeout)
        if (!queryTimeout.isNone()) {
            try {
                var timeout = Int64.parse(queryTimeout.getOrThrow())
                sendCommand("set session max_execution_time = ${timeout}")
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("parse query_timeout failed")
            }
        }

        var updateTimeout = options.get(Params.UpdateTimeout)
        if (!updateTimeout.isNone()) {
            try {
                var timeout = Int64.parse(updateTimeout.getOrThrow())
                sendCommand("set session lock_wait_timeout = ${timeout}")
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("parse update_timeout failed")
            }
        }
    }
}
