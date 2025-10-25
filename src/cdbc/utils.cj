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

protected func insertCount(sql: String): Int {
    let lower = sql.toAsciiLower()
    let index = lower.indexOf("values") ?? throw SqlException()
    let values = lower[index + "values".size..lower.size]
    var depth = 0
    var count = 0
    for(i in values.runes()) {
        if(i == r'(') {
            depth ++
            if(depth == 1) {
                count ++
            }
        }else if(i == r')') {
            depth --
        }
    }
    return count
}
