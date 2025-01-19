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

    public mut override prop deferrableMode: TransactionDeferrableMode {
        get() {
            throw UnsupportedException()
        }
        set(_) {
            throw UnsupportedException()
        }
    }

    public override func begin(): Unit {
        checkResource()
        transaction.begin()
    }

    public override func commit(): Unit {
        checkResource()
        transaction.commit()
    }

    public override func rollback(): Unit {
        checkResource()
        transaction.rollback()
    }

    public override func save(savePointName: String): Unit {
        checkResource()
        transaction.setSavepoint(savePointName)
    }

    public override func rollback(savePointName: String): Unit {
        checkResource()
        transaction.rollback(savePointName)
    }

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
