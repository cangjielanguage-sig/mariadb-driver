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
protected package mariadb.protocol

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

protected class ResetCommand <: Command {

    private let statementId: UInt32

    internal init(statementId: UInt32){
        super(StmtReset)
        this.statementId = statementId
    }

    public override func pack(): Unit {
        super.pack()
        this.statementId |> buffer.writeInt4
    }
}


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