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
import mysqlclient4cj.connection.ResponseErrorException
import mysqlclient4cj.connection.MySqlConnectionFactory
import mysqlclient4cj.connection.ConnectFailedException
import mysqlclient4cj.protocol.ParameterConvertException

public class ConnectionImpl <: Connection {
    
    private static const QUERY_ISO_LEVEL_SQL: String = "SELECT @@transaction_isolation"

    private static const QUERY_ACCESS_MODE_SQL = "SELECT @@transaction_read_only"

    private static const QUERY_AUTO_COMMIT = "SELECT @@autocommit"

    private static const START_TRANSACTION_SQL = "BEGIN"

    private static const COMMIT_TRANSACTION_SQL = "COMMIT"

    private static const ROLLBACK_TRANSACTION_SQL = "ROLLBACK"

    private static const SAVE_TRANSACTION_SQL = "SAVEPOINT"

    private static const ROLLBACK_TO_SAVEPOINT_SQL = "ROLLBACK TO"

    private static const RELEASE_SAVEPOINT_SQL = "RELEASE SAVEPOINT"

    private static const CHANGE_TO_READ_UNCOMMITED_SQL = "SET SESSION transaction_isolation = 'READ-UNCOMMITTED'"

    private static const CHANGE_TO_READ_COMMITED_SQL = "SET SESSION transaction_isolation = 'READ-COMMITTED'"

    private static const CHANGE_TO_REPEATABLE_READ_SQL = "SET SESSION transaction_isolation = 'REPEATABLE-READ'"

    private static const CHANGE_TO_READ_SERIALIZABLE_SQL = "SET SESSION transaction_isolation = 'SERIALIZABLE'"

    private static const CHANGE_TO_READ_WRITE_SQL = "SET SESSION transaction_read_only = OFF"

    private static const CHANGE_TO_READ_ONLY_SQL = "SET SESSION transaction_read_only = ON"

    private static const CLOSE_AUTO_COMMIT = "SET SESSION autocommit = 0"

    private static const OPEN_AUTO_COMMIT = "SET SESSION autocommit = 1"

    private static const SET_SCHEMA = "USE"

    private static const GET_SCHEMA = "SELECT DATABASE()"

    private var connection: MySqlConnection

    private var options: Map<String, String>

    public ConnectionImpl(options: Map<String, String>) {
        this.options = options
        try {
            connection = MySqlConnectionFactory.createAuthedConnection(options)
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
        var prepareMode: String = options.get(Params.PrepareMode).getOrDefault({=> "client"})
        if (prepareMode == "server") {
            return ServerPrepareStatement(sql, this)
        } else if (prepareMode == "client") {
            return ClientPrepareStatement(sql, this)
        } else {
            throw SqlException("Unknow prepare mode: ${prepareMode} option: auto, server or client")
        }
    }

    public override func getAutoCommit(): Bool {
        checkResourceAvailability()
        var result = connection.sendQuery(QUERY_AUTO_COMMIT)
        if (!result.next() || result.rowSize != 1 || result.columnSize != 1) {
            throw SqlException("Query transaction isolation level failed")
        }
        var autoCommit: String = result.getString(1).getOrThrow()
        match (autoCommit) {
            case "0" => false
            case "1" => true
            case _ => throw SqlException("Unknown transaction isolation level")
        }
    }

    public override func setAutoCommit(autoCommit: Bool): Unit {
        checkResourceAvailability()
        var changeAutoCommite = match (autoCommit) {
            case true => OPEN_AUTO_COMMIT
            case false => CLOSE_AUTO_COMMIT
        }
        connection.sendCommand(changeAutoCommite)
    }

    public override func getTransactionIsolation(): IsolationLevel {
        checkResourceAvailability()
        var result = connection.sendQuery(QUERY_ISO_LEVEL_SQL)
        if (!result.next() || result.rowSize != 1 || result.columnSize != 1) {
            throw SqlException("Query transaction isolation level failed")
        }
        var isoLevel: String = result.getString(1).getOrThrow()
        match (isoLevel) {
            case "READ-UNCOMMITTED" => ReadUncommitted
            case "READ-COMMITTED" => ReadCommitted
            case "REPEATABLE-READ" => RepeatableRead
            case "SERIALIZABLE" => Serializable
            case _ => throw SqlException("Unknown transaction isolation level")
        }
    }

    public override func setTransactionIsolation(level: IsolationLevel): Unit {
        checkResourceAvailability()
        var changeIsoLevel = match (level) {
            case ReadUncommitted => CHANGE_TO_READ_UNCOMMITED_SQL
            case ReadCommitted => CHANGE_TO_READ_COMMITED_SQL
            case RepeatableRead => CHANGE_TO_REPEATABLE_READ_SQL
            case Serializable => CHANGE_TO_READ_SERIALIZABLE_SQL
            case Unspecified => CHANGE_TO_REPEATABLE_READ_SQL
        }
        connection.sendCommand(changeIsoLevel)
    }

    public override func begin(): Unit {
        checkResourceAvailability()
        connection.sendCommand(START_TRANSACTION_SQL)
    }

    public override func commit(): Unit {
        checkResourceAvailability()
        connection.sendCommand(COMMIT_TRANSACTION_SQL)
    }

    public override func rollback(): Unit {
        checkResourceAvailability()
        connection.sendCommand(ROLLBACK_TRANSACTION_SQL)
    }

    public override func setSavepoint(name: String): Unit {
        checkResourceAvailability()
        connection.sendCommand("${SAVE_TRANSACTION_SQL} ${name}")
    }

    public override func rollback(name: String): Unit {
        checkResourceAvailability()
        connection.sendCommand("${ROLLBACK_TO_SAVEPOINT_SQL} ${name}")
    }

    public override func releaseSavepoint(name: String): Unit {
        checkResourceAvailability()
        connection.sendCommand("${RELEASE_SAVEPOINT_SQL} ${name}")
    }

    public override func setReadOnly(readOnly: Bool): Unit {
        checkResourceAvailability()
        var changeAccessMode = match (readOnly) {
            case false => CHANGE_TO_READ_WRITE_SQL
            case true => CHANGE_TO_READ_ONLY_SQL
        }
        connection.sendCommand(changeAccessMode)
    }

    public override func isReadOnly(): Bool {
        checkResourceAvailability()
        var result = connection.sendQuery(QUERY_ACCESS_MODE_SQL)
        if (!result.next() || result.rowSize != 1 || result.columnSize != 1) {
            throw SqlException("Query transaction isolation level failed")
        }
        var accessMode: String = result.getString(1).getOrThrow()
        match (accessMode) {
            case "0" => false
            case "1" => true
            case _ => throw SqlException("Unkonw transaction access mode")
        }
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
