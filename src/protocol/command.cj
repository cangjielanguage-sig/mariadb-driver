/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.collection.*
import std.time.*
import encoding.json.*
import std.convert.*
import encoding.hex.*
import std.io.*
import std.math.numeric.*

/*
 * Command Phase
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_command_phase.html
 */
protected abstract class Command <: Request {

    private let _commandType: CommandType

    protected init(command: CommandType) {
        super(1, 0)
        _commandType = command
    }

    protected open override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        list.append(_commandType.value())
        return list.toArray()
    }
}

/*
 * Text Protocol based SQL query
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query.html
 */
protected class QueryCommand <: Command {

    private let _query: String

    protected init(query: String) {
        super(Query)
        this._length += UInt32(query.size)
        _query = query
    }

    protected override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        list.appendAll(_query.toArray())
        return list.toArray()
    }

}

/*
 * Creates a prepared statement for the passed query string.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_prepare.html#sect_protocol_com_stmt_prepare_response
 */
protected class PrepareCommand <: Command {

    private let _sql: String

    protected init(sql: String) {
        super(StmtPrepare)
        this._length += UInt32(sql.size)
        _sql = sql
    }

    public override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        list.appendAll(_sql.toArray())
        return list.toArray()
    }

}


/*
 * Fetches the requested amount of rows from a resultset produced by COM_STMT_EXECUTE
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_fetch.html
 */
protected class FetchCommand <: Command {
    
    private var statemetnId: UInt32

    private var numRows: UInt32

    protected init(statemetnId: UInt32, numRows: UInt32){
        super(StmtFetch)
        this._length += 8
        this.statemetnId = statemetnId
        this.numRows = numRows
    }

    protected override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        list.appendAll(uInt32ToLittleEndian(statemetnId))
        list.appendAll(uInt32ToLittleEndian(numRows))
        return list.toArray()
    }

}

/*
* COM_STMT_CLOSE deallocates a prepared statement.
* referened document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_close.html
*/
protected class CloseCommand <: Command {

    private var _statementId: UInt32

    protected init(id: UInt32){
        super(StmtClose)
        this._length += 4
        _statementId = id
    }

    protected override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        list.appendAll(uInt32ToLittleEndian(_statementId))
        return list.toArray()
    }
}

/*
 * COM_STMT_RESET resets the data of a prepared statement which was accumulated with
 * referened document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_reset.html
 */
protected class ResetCommand <: Command {

    private var _statementId: UInt32

    internal init(statementId: UInt32){
        super(StmtClose)
        this._length += 4
        _statementId = statementId
    }

    public override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        list.appendAll(uInt32ToLittleEndian(_statementId))
        return list.toArray()
    }
}

/*
 * Sends the data for a parameter.
 * referened document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_send_long_data.html
 */
protected class SendLongDataCommand <: Command {

    private var statemetnId: UInt32

    private var parameterId: UInt16

    private var data: Array<Byte>

    protected init(statemetnId: UInt32, parameterId: UInt16, data: Array<Byte>){
        super(StmtSendLongData)
        this._length += UInt32(data.size + 6)
        this.statemetnId = statemetnId
        this.parameterId = parameterId
        this.data = data
    }

    public override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        list.appendAll(uInt32ToLittleEndian(statemetnId))
        list.appendAll(uInt16ToLittleEndian(parameterId))
        list.appendAll(data)
        return list.toArray()
    }

}