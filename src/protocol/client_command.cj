/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mysql.protocol

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
        this.commandType.value() |> buffer.writeInt1
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
        this.query |> buffer.writeString
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
        this.sql |> buffer.writeString
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
        this.statemetnId |> buffer.writeInt4
        this.numRows |> buffer.writeInt4
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
        this.statementId |> buffer.writeInt4
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
        this.statementId |> buffer.writeInt4
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
        this.statemetnId |> buffer.writeInt4
        this.parameterId |> buffer.writeInt2
        this.data |> buffer.write
    }

}