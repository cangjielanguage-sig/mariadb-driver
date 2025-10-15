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
package mysql.cdbc

import std.sync.*
import std.collection.*
import std.database.sql.*
import mysql.connection.*

public class ConnectionImpl <: Connection {

    private var currentState: ConnectionState

    private var connection: MySqlConnection

    private var transaction: Transaction

    private var options: Map<String, String>

    public override prop state: ConnectionState {
        get() {
            return currentState
        }
    }

    public ConnectionImpl(options: Map<String, String>) {
        this.currentState = ConnectionState.Connecting
        this.options = options
        try {
            this.connection = MySqlConnectionFactory.createAuthedConnection(options)
        } catch (e: ConnectFailedException) {
            currentState = ConnectionState.Broken
            throw e
        }
        this.transaction = TransactionImpl(connection.createTransaction())
        this.currentState = ConnectionState.Connected
    }

    public override func getMetaData(): Map<String, String> {
        checkResource()
        return options
    }

    public override func prepareStatement(sql: String): Statement {
        checkResource()
        checkEmptySql(sql)
        if (let Some(mode) <- options.get(Params.PrepareMode)) {
            match (mode) {
                case "server" => return ServerPrepareStatement(sql, this)
                case "client" => return ClientPrepareStatement(sql, this)
                case other => throw ConnectFailedException("Unknow prepare.mode value: ${other}")
            }
        }
        return ServerPrepareStatement(sql, this)
    }

    public override func createTransaction(): Transaction {
        checkResource()
        return transaction
    }

    public override func close() {
        checkResource()
        synchronized(getConnectionMutex()) {
            currentState = ConnectionState.Closed
            connection.close()
        }
    }

    public override func isClosed(): Bool {
        return connection.isClosed()
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
            return connection.executeQueryPrepare(prepare.id, params)
        } catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func executeQueryPrepareWithCurosr(prepare: PrepareResult, params: Array<Any>, fetchSize: UInt32): ResultSet {
        try {
            return connection.executeQueryPrepareWithCurosr(prepare.id, params, fetchSize)
        } catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        try {
            return connection.executeUpdatePrepare(prepare, params)
        } catch (e: ResponseErrorException) {
            throw SqlException(e.message)
        }
    }

    protected func closePrepare(id: UInt32) {
        return connection.closePrepare(id)
    }

    protected func getConnectionMutex(): Mutex {
        return connection.connectionMutex
    }

    private func checkEmptySql(sql: String) {
        if (sql.size == 0) {
            throw SqlException("Empty SQL")
        }
    }

    private func checkResource() {
        if (isClosed()) {
            throw SqlException("The database Connection has been closed")
        }
    }
}
