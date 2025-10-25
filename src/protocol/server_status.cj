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
            case InTransaction => 1 << 0
            case AutoCommit => 1 << 1
            case MoreResults => 1 << 2
            case NoGoodIndexUsed => 1 << 3
            case NoIndexUsed => 1 << 4
            case CursorExists => 1 << 5
            case LastRowSend => 1 << 6
            case DbDropped => 1 << 7
            case NoBackslashEscapes => 1 << 8
            case MetaDataChanged => 1 << 9
            case QueryWasSlow => 1 << 10
            case PsOutParams => 1 << 11
            case InStransReadOnly => 1 << 12
            case SessionStateChanged => 1 << 13
        }
    }
}