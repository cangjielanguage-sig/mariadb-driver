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
package mariadb.cdbc

import std.database.sql.*
import mariadb.protocol.*

public class ColumnInfoImpl <: ColumnInfo {

    private let colName: String

    private let colType: String

    private let colSize: Int64

    private let colLength: Int64

    private let colScale: Int64

    private let colNullable: Bool

    protected init(definition: ColumnDefinition) {
        let unsigned = definition.hasFlag(Unsigned)
        this.colName = definition.name
        this.colType = definition.columnType.cangjieType(unsigned)
        this.colSize = Int64(definition.columnLength)
        this.colLength = Int64(definition.columnLength)
        this.colScale = Int64(definition.decimals)
        this.colNullable = !definition.hasFlag(NotNull)
    }

    public override prop name: String {
        get() {
            return colName
        }
    }

    public override prop typeName: String {
        get() {
            return colType
        }
    }

    public override prop displaySize: Int64 {
        get() {
            return colSize
        }
    }

    public override prop length: Int64 {
        get() {
            return colLength
        }
    }

    public override prop scale: Int64 {
        get() {
            return colScale
        }
    }

    public override prop nullable: Bool {
        get() {
            return colNullable
        }
    }
}
