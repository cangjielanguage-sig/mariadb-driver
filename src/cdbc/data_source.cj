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

import std.sync.*
import std.collection.*
import std.database.sql.*

public class DatasourceImpl <: Datasource {

    private var optinos: HashMap<String, String>

    private var closed: AtomicBool

    public DatasourceImpl() {
        optinos = HashMap<String, String>()
        closed = AtomicBool(false)
    }
    
    public override func setOption(key: String, value: String): Unit {
        checkResource()
        optinos.add(key, value)
    }

    public override func connect(): Connection {
        checkResource()
        return ConnectionImpl(optinos)
    }

    public override func close() {
        checkResource()
        closed.store(true)
    }

    public override func isClosed(): Bool {
        return closed.load()
    }

    private func checkResource() {
        if(isClosed()){
            throw SqlException("The data Source has been closed")
        }
    } 
}
