/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.cdbc

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
