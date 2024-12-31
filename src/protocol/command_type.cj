/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol

/*
* A list of all MySQL protocol commands.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/my__command_8h.html
*/
protected enum CommandType {
    | Sleep
    | Quit
    | InitDB
    | Query
    | FieldList
    | CreateDB
    | DropDB
    | Refresh
    | Shutdown
    | Statistics
    | ProcessInfo
    | Connect
    | PreocessKill
    | Debug
    | Ping
    | Time
    | DelayedInsert
    | ChangeUser
    | BinLogDump
    | TableDump
    | ConnectOut
    | StmtRegisterSlave
    | StmtPrepare
    | StmtExecute
    | StmtSendLongData
    | StmtClose
    | StmtReset
    | SetOption
    | StmtFetch
    | Daemon
    | BingLongDumpGTID
    | ResetConnection
    | Clone 
    | SubscribeGroupReplicationStream

    public func value(): Byte{
        match(this){
            case Sleep => 0x00
            case Quit => 0x01
            case InitDB => 0x02
            case Query => 0x03
            case FieldList => 0x04
            case CreateDB => 0x05
            case DropDB => 0x06
            case Refresh => 0x07
            case Shutdown => 0x08
            case Statistics => 0x09
            case ProcessInfo => 0x0A
            case Connect => 0x0B
            case PreocessKill => 0x0C
            case Debug => 0x0D
            case Ping => 0xE
            case Time => 0x0F
            case DelayedInsert => 0x10
            case ChangeUser => 0x11
            case BinLogDump => 0x12
            case TableDump => 0x13
            case ConnectOut => 0x14
            case StmtRegisterSlave => 0x15
            case StmtPrepare => 0x16
            case StmtExecute => 0x17
            case StmtSendLongData => 0x18
            case StmtClose => 0x19
            case StmtReset => 0x1A
            case SetOption => 0x1B
            case StmtFetch => 0x1C
            //uncheck
            case Daemon => 0x1D
            case BingLongDumpGTID => 0x1E
            case ResetConnection => 0x1F
            case Clone => 0x20
            case SubscribeGroupReplicationStream => 0x21
        }
    }

    public static func of(value: Byte): CommandType{
        match(value){
            case 0x00 => Sleep
            case 0x01 => Quit
            case 0x02 => InitDB
            case 0x03 => Query
            case 0x04 => FieldList
            case 0x05 => CreateDB
            case 0x06 => DropDB
            case 0x07 => Refresh
            case 0x08 => Shutdown
            case 0x09 => Statistics
            case 0x0A => ProcessInfo
            case 0x0B => Connect
            case 0x0C => PreocessKill
            case 0x0D => Debug
            case 0x0E => Ping
            case 0x0F => Time
            case 0x10 => DelayedInsert
            case 0x11 => ChangeUser
            case 0x12 => BinLogDump
            case 0x13 => TableDump
            case 0x14 => ConnectOut
            case 0x15 => StmtRegisterSlave
            case 0x16 => StmtPrepare
            case 0x17 => StmtExecute
            case 0x18 => StmtSendLongData
            case 0x19 => StmtClose
            case 0x1A => StmtReset
            case 0x1B => SetOption
            case 0x1C => StmtFetch
            case 0x1D => Daemon
            case 0x1E => BingLongDumpGTID
            case 0x1F => ResetConnection
            case 0x20 => Clone
            case 0x21 => SubscribeGroupReplicationStream
            case _ => throw Exception("Don't have this CommandType by value: ${value}")
        }
    }
}