/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.request

import mysql.util.*
import mysql.protocol.*

/*
 * Command Phase
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_command_phase.html
 */
protected abstract class Command <: Request {

    private let commandType: CommandType

    protected init(commandType: CommandType) {
        super(0)
        this.commandType = commandType
    }

    protected open override func pack(): Unit {
        super.pack()
        this.commandType.value() |> pack
    }

}

/*
 * Text Protocol based SQL query
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query.html
 */
protected class QueryCommand <: Command {

    private let query: String

    protected init(query: String) {
        super(Query)
        this.query = query
    }

    protected override func pack(): Unit {
        super.pack()
        this.query.toArray() |> pack
    }

}

/*
 * Creates a prepared statement for the passed query string.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_prepare.html#sect_protocol_com_stmt_prepare_response
 */
protected class PrepareCommand <: Command {

    private let sql: String

    protected init(sql: String) {
        super(StmtPrepare)
        this.sql = sql
    }

    public override func pack(): Unit{
        super.pack()
        this.sql.toArray() |> pack
    }

}


/*
 * Fetches the requested amount of rows from a resultset produced by COM_STMT_EXECUTE
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_fetch.html
 */
protected class FetchCommand <: Command {
    
    private let statemetnId: UInt32

    private let numRows: UInt32

    protected init(statemetnId: UInt32, numRows: UInt32){
        super(StmtFetch)
        this.statemetnId = statemetnId
        this.numRows = numRows
    }

    protected override func pack(): Unit {
        super.pack()
        this.statemetnId.toLittleEndian() |> pack
        this.numRows.toLittleEndian() |> pack
    }

}

/*
* COM_STMT_CLOSE deallocates a prepared statement.
* referened document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_close.html
*/
protected class CloseCommand <: Command {

    private let statementId: UInt32

    protected init(id: UInt32){
        super(StmtClose)
        this.statementId = id
    }

    protected override func pack(): Unit {
        super.pack()
        this.statementId.toLittleEndian() |> pack
    }
}

/*
 * COM_STMT_RESET resets the data of a prepared statement which was accumulated with
 * referened document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_reset.html
 */
protected class ResetCommand <: Command {

    private let statementId: UInt32

    internal init(statementId: UInt32){
        super(StmtClose)
        this.statementId = statementId
    }

    public override func pack(): Unit {
        super.pack()
        this.statementId.toLittleEndian() |> pack
    }
}

/*
 * Sends the data for a parameter.
 * referened document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_send_long_data.html
 */
protected class SendLongDataCommand <: Command {

    private let statemetnId: UInt32

    private let parameterId: UInt16

    private let data: Array<Byte>

    protected init(statemetnId: UInt32, parameterId: UInt16, data: Array<Byte>) {
        super(StmtSendLongData)
        this.statemetnId = statemetnId
        this.parameterId = parameterId
        this.data = data
    }

    public override func pack(): Unit {
        super.pack()
        this.statemetnId.toLittleEndian() |> pack
        this.parameterId.toLittleEndian() |> pack
        this.data |> pack
    }

}