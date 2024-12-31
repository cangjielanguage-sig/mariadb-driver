/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol

/*
* Capabilities Flags
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/mysql__com_8h.html#a1d854e841086925be1883e4d7b4e8cad
*/
protected enum ServerStatus {

    | InTransaction
    | AutoCommit
    | MoreResults
    | NoGoodIndexUsed
    | NoIndexUsed
    | CursorExists
    | LastRowSend
    | DbDropped
    | NoBackslashEscapes
    | MetaDataChanged
    | QueryWasSlow
    | PsOutParams
    | InStransReadOnly
    | SessionStateChanged

    protected func value(): UInt16 {
        match (this) {
            case InTransaction => return 1 << 0
            case AutoCommit => return 1 << 1
            case MoreResults => return 1 << 2
            case NoGoodIndexUsed => return 1 << 3
            case NoIndexUsed => return 1 << 4
            case CursorExists => return 1 << 5
            case LastRowSend => return 1 << 6
            case DbDropped => return 1 << 7
            case NoBackslashEscapes => return 1 << 8
            case MetaDataChanged => return 1 << 9
            case QueryWasSlow => return 1 << 10
            case PsOutParams => return 1 << 11
            case InStransReadOnly => return 1 << 12
            case SessionStateChanged => return 1 << 13
        }
    }
}