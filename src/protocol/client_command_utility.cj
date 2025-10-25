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

/*
 * Change the default schema of the connection
 * referenced document: https://dev.mariadb.com/doc/dev/mariadb-server/latest/page_protocol_com_init_db.html
 */
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

/*
 * Get a human readable string of some internal status vars.
 * referenced document: https://dev.mariadb.com/doc/dev/mariadb-server/latest/page_protocol_com_statistics.html
 */
protected class StatisticsCommand <: Command {

    protected init() {
        super(Statistics)
    }

}

/*
 * Dump debug info to server's stdout
 * referenced document: https://dev.mariadb.com/doc/dev/mariadb-server/latest/page_protocol_com_debug.html
 */
protected class DebugCommand <: Command {
    protected init() {
        super(Debug)
    }
}

/*
 * Check if the server is alive
 * referenced document: https://dev.mariadb.com/doc/dev/mariadb-server/latest/page_protocol_com_ping.html
 */
protected class PingCommand <: Command {
    protected init() {
        super(Ping)
    }
}

/*
 * Resets the session state
 * referenced document: https://dev.mariadb.com/doc/dev/mariadb-server/latest/page_protocol_com_reset_connection.html
 */
protected class ResetConnectionCommand <: Command {
    protected init() {
        super(ResetConnection)
    }
}

/*
 * Sets options for the current connection
 * referenced document: https://dev.mariadb.com/doc/dev/mariadb-server/latest/page_protocol_com_set_option.html
 */
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