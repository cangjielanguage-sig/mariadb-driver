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

protected enum ColumnFlag {
    
    | NotNull
    | PrimaryKey
    | UniqueKey
    | MultipleKey
    | Blob
    | Unsigned
    | ZeroFill
    | Binary
    | Enum
    | AutoIncrement
    | Timestamp
    | Set
    | NoDefaultValue
    | OnUpdateNow
    | PartKey
    | Num

    internal func value(): UInt16 {
        match (this) {
            case NotNull => 1 << 0
            case PrimaryKey => 1 << 1
            case UniqueKey => 1 << 2
            case MultipleKey => 1 << 3
            case Blob => 1 << 4
            case Unsigned => 1 << 5
            case ZeroFill => 1 << 6
            case Binary => 1 << 7
            case Enum => 1 << 8
            case AutoIncrement => 1 << 9
            case Timestamp => 1 << 10
            case Set => 1 << 11
            case NoDefaultValue => 1 << 12
            case OnUpdateNow => 1 << 13
            case PartKey => 1 << 14
            case Num => 1 << 15
        }
    }
}