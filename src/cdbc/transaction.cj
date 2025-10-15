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
                synchronized(connectionMutex()) {
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
            synchronized(connectionMutex()) {
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

    private func connectionMutex() {
        transaction.connection.connectionMutex
    }

    private func checkResource(){
        if(transaction.connection.isClosed()) {
            throw SqlException("The database Connection has been closed")
        }
    }
}
