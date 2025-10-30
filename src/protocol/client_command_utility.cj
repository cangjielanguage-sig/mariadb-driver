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

protected class QuitCommand <: Command {

    protected init() {
        super(Quit)
    }

}

protected class InitDbCommand <: Command {

    private let database: String

    protected init(database: String) {
        super(InitDB)
        this.database = database
    }

    protected override func pack(): Unit {
        super.pack()
        database |> buffer.writeString
    }
}

protected class StatisticsCommand <: Command {

    protected init() {
        super(Statistics)
    }

}

protected class DebugCommand <: Command {
    protected init() {
        super(Debug)
    }
}

protected class PingCommand <: Command {
    protected init() {
        super(Ping)
    }
}

protected class ResetConnectionCommand <: Command {
    protected init() {
        super(ResetConnection)
    }
}

protected class SetOptionCommand <: Command {

    private let operation: StatementOption

    protected init(option: StatementOption) {
        super(SetOption)
        operation = option
    }

    protected override func pack(): Unit {
        super.pack()
        operation.value() |> buffer.writeInt2
    }

}