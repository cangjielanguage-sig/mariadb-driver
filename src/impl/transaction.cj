/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.impl

import std.database.sql.*
import cjmd.connection.*
import std.sync.*

class TransactionImpl <: Transaction {
    
    private static const QUERY_ISO_LEVEL_SQL: String = "SELECT @@transaction_isolation"

    private static const QUERY_ACCESS_MODE_SQL = "SELECT @@transaction_read_only"

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

    private var _connection: ConnectionImpl

    private var _isoLevel: TransactionIsoLevel

    private var _accessMode: TransactionAccessMode = ReadWrite

    private var _deferrableMode: TransactionDeferrableMode = TransactionDeferrableMode.NotDeferrable

    public TransactionImpl(connection: ConnectionImpl) {
        _connection = connection
        _accessMode = ReadWrite
        _isoLevel = RepeatableRead
        checkResourceAvailability()
        var result = _connection.sendQuery(QUERY_ISO_LEVEL_SQL)
        if (!result.next() || result.rowSize != 1 || result.columnSize != 1) {
            throw SqlException("Query transaction isolation level failed")
        }
        var isoLevel: String = result.getString(1).getOrThrow()
        match (isoLevel) {
            case "READ-UNCOMMITTED" => _isoLevel = ReadUncommitted
            case "READ-COMMITTED" => _isoLevel = ReadCommitted
            case "REPEATABLE-READ" => _isoLevel = RepeatableRead
            case "SERIALIZABLE" => _isoLevel = Serializable
            case _ => throw SqlException("Unknown transaction isolation level")
        }

        result = _connection.sendQuery(QUERY_ACCESS_MODE_SQL)
        if (!result.next() || result.rowSize != 1 || result.columnSize != 1) {
            throw SqlException("Query transaction isolation level failed")
        }
        var accessMode: String = result.getString(1).getOrThrow()
        match(accessMode){
            case "0" => _accessMode = ReadWrite
            case "1" => _accessMode = ReadOnly
            case _ => throw SqlException("Unkonw transaction access mode")
        } 
    }

    /*获取数据库事务隔离级别*/
    public mut override prop isoLevel: TransactionIsoLevel {
        get() {
            return _isoLevel
        }
        set(value) {
            checkResourceAvailability()
            synchronized(_connection.getConnectionMutex()) {
                if (value != _isoLevel) {
                    var changeIsoLevel = match (value) {
                        case TransactionIsoLevel.ReadUncommitted => CHANGE_TO_READ_UNCOMMITED_SQL
                        case TransactionIsoLevel.ReadCommitted => CHANGE_TO_READ_COMMITED_SQL
                        case TransactionIsoLevel.RepeatableRead => CHANGE_TO_REPEATABLE_READ_SQL
                        case TransactionIsoLevel.Serializable => CHANGE_TO_READ_SERIALIZABLE_SQL
                        case TransactionIsoLevel.Unspecified => CHANGE_TO_REPEATABLE_READ_SQL
                        case _ => throw SqlException("Unsupported Transaction IsoLevel")
                    }
                    _connection.sendCommand(changeIsoLevel)
                    _isoLevel = value
                }
            }
        }
    }

    /*获取数据库事务访问模式*/
    public mut override prop accessMode: TransactionAccessMode {
        get() {
            return _accessMode
        }
        set(value) {
            checkResourceAvailability()
            synchronized(_connection.getConnectionMutex()){
                if(value != _accessMode){
                    var changeAccessMode = match(value){
                        case TransactionAccessMode.ReadWrite => CHANGE_TO_READ_WRITE_SQL
                        case TransactionAccessMode.ReadOnly =>  CHANGE_TO_READ_ONLY_SQL
                        case TransactionAccessMode.Unspecified => CHANGE_TO_READ_WRITE_SQL
                    }
                    _connection.sendCommand(changeAccessMode)
                    _accessMode = value
                }
            }
        }
    }

    /*获取数据库事务延迟模式。*/
    public mut override prop deferrableMode: TransactionDeferrableMode {
        get() {
            return _deferrableMode
        }
        set(value) {
            this._deferrableMode = value
        }
    }

    /*开始数据库事务。*/
    public override func begin(): Unit {
        checkResourceAvailability()
        _connection.sendCommand(START_TRANSACTION_SQL)
    }

    /*提交数据库事务。*/
    public override func commit(): Unit {
        checkResourceAvailability()
        _connection.sendCommand(COMMIT_TRANSACTION_SQL)
    }

    /*从挂起状态回滚事务。*/
    public override func rollback(): Unit {
        checkResourceAvailability()
        synchronized(_connection.getConnectionMutex()) {
            _connection.sendCommand(ROLLBACK_TRANSACTION_SQL)
        }
    }

    /*在事务中创建一个指定名称的保存点，可用于回滚此保存点之后的事务。*/
    public override func save(savePointName: String): Unit {
        checkResourceAvailability()
        _connection.sendCommand("${SAVE_TRANSACTION_SQL} ${savePointName}")
    }

    /*回滚事务至指定保存点名称。*/
    public override func rollback(savePointName: String): Unit {
        checkResourceAvailability()
        _connection.sendCommand("${ROLLBACK_TO_SAVEPOINT_SQL} ${savePointName}")
    }

    /*销毁先前在当前事务中定义的保存点。这允许系统在事务结束之前回收一些资源。*/
    public override func release(savePointName: String): Unit {
        checkResourceAvailability()
        _connection.sendCommand("${RELEASE_SAVEPOINT_SQL} ${savePointName}")
    }

    private func checkResourceAvailability(){
        if(_connection.isClosed()){
            throw SqlException("The database Connection has been closed")
        }
    }
}
