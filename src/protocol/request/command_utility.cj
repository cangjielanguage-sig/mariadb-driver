/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol.request

import mysql.protocol.*

/*
 * Tells the server that the client wants it to close the connection.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_quit.html
 */
protected class QuitCommand <: Command {

    protected init() {
        super(Quit)
    }

}

/*
 * Change the default schema of the connection
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_init_db.html
 */
protected class InitDbCommand <: Command {

    private let database: String

    protected init(database: String) {
        super(InitDB)
        this.database = database
    }

    protected override func pack(): Unit {
        super.pack()
        buf.appendAll(database.toArray())
    }
}

/*
 * Get a human readable string of some internal status vars.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_statistics.html
 */
protected class StatisticsCommand <: Command {

    protected init() {
        super(Statistics)
    }

}

/*
 * Dump debug info to server's stdout
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_debug.html
 */
protected class DebugCommand <: Command {
    protected init() {
        super(Debug)
    }
}

/*
 * Check if the server is alive
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_ping.html
 */
protected class PingCommand <: Command {
    protected init() {
        super(Ping)
    }
}

/*
 * Resets the session state
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_reset_connection.html
 */
protected class ResetConnectionCommand <: Command {
    protected init() {
        super(ResetConnection)
    }
}

/*
 * Sets options for the current connection
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_set_option.html
 */
protected class SetOptionCommand <: Command {

    private let operation: StatementOption

    protected init(option: StatementOption) {
        super(SetOption)
        operation = option
    }

    protected override func pack(): Unit {
        super.pack()
        buf.appendAll(operation.value().toLittleEndian())
    }

}