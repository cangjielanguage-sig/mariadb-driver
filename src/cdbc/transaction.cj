/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysql.cdbc

import std.database.sql.*
import mysql.connection.*

class TransactionImpl <: Transaction {
    
    private var transaction: MySqlTransaction

    private var isolationLevel: TransactionIsoLevel

    private var accessPower: TransactionAccessMode = ReadWrite

    public init(transaction: MySqlTransaction) {
        this.transaction = transaction
        this.accessPower = ReadWrite
        this.isolationLevel = RepeatableRead
        match (transaction.getTransactionIsolation()) {
            case "READ-UNCOMMITTED" => 
                this.isolationLevel = ReadUncommitted
            case "READ-COMMITTED" => 
                this.isolationLevel = ReadCommitted
            case "REPEATABLE-READ" => 
                this.isolationLevel = RepeatableRead
            case "SERIALIZABLE" => 
                this.isolationLevel = Serializable
            case _ => throw SqlException("Unknown transaction isolation level")
        }
        match(transaction.isReadOnly()) {
            case true => 
                this.accessPower = ReadOnly
            case false => 
                this.accessPower = ReadWrite
        } 
    }

    /*获取数据库事务隔离级别*/
    public mut override prop isoLevel: TransactionIsoLevel {
        get() {
            return isolationLevel
        }
        set(value) {
            checkResource()
            if (value != isolationLevel) {
                synchronized(transaction.connection.mutex) {
                    let level = match (value) {
                        case ReadUncommitted => "READ-UNCOMMITTED"
                        case ReadCommitted => "READ-COMMITTED"
                        case RepeatableRead => "REPEATABLE-READ"
                        case Serializable => "SERIALIZABLE"
                        case Unspecified => "REPEATABLE-READ"
                        case _ => throw UnsupportedException()
                    }
                    transaction.setTransactionIsolation(level)
                    this.isolationLevel = value
                }
            }
        }
    }

    /*获取数据库事务访问模式*/
    public mut override prop accessMode: TransactionAccessMode {
        get() {
            return accessPower
        }
        set(value) {
            checkResource()
            synchronized(transaction.connection.mutex) {
                if(value != accessMode){
                    match(value){
                        case ReadWrite => transaction.setReadOnly(false)
                        case ReadOnly =>  transaction.setReadOnly(true)
                        case Unspecified => transaction.setReadOnly(false)
                    }
                    accessPower = value
                }
            }
        }
    }

    /*获取数据库事务延迟模式。*/
    public mut override prop deferrableMode: TransactionDeferrableMode {
        get() {
            return deferrableMode
        }
        set(_) {

        }
    }

    /*开始数据库事务。*/
    public override func begin(): Unit {
        checkResource()
        transaction.begin()
    }

    /*提交数据库事务。*/
    public override func commit(): Unit {
        checkResource()
        transaction.commit()
    }

    /*从挂起状态回滚事务。*/
    public override func rollback(): Unit {
        checkResource()
        transaction.rollback()
    }

    /*在事务中创建一个指定名称的保存点，可用于回滚此保存点之后的事务。*/
    public override func save(savePointName: String): Unit {
        checkResource()
        transaction.setSavepoint(savePointName)
    }

    /*回滚事务至指定保存点名称。*/
    public override func rollback(savePointName: String): Unit {
        checkResource()
        transaction.rollback(savePointName)
    }

    /*销毁先前在当前事务中定义的保存点。这允许系统在事务结束之前回收一些资源。*/
    public override func release(savePointName: String): Unit {
        checkResource()
        transaction.releaseSavepoint(savePointName)
    }

    private func checkResource(){
        if(transaction.connection.isClosed()) {
            throw SqlException("The database Connection has been closed")
        }
    }
}
