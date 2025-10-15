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
package mysql.cdbc

import std.database.sql.*

public class UpdateResultImpl <: UpdateResult {
    
    private var effectRows: Int64 = 0
    
    private var lastIndex: Int64 = 0

    public UpdateResultImpl(effectRowCount: Int64, lastInsertId: Int64){
        this.effectRows= effectRowCount
        this.lastIndex = lastInsertId
    }

    override public prop rowCount: Int64{
        get() {
            return effectRows
        }
    }

    override public prop lastInsertId: Int64{
        get() {
            return lastIndex
        }
    }


}