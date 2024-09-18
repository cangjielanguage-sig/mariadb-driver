/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.cdbc

import std.database.sql.*
import std.socket.*
import std.collection.*
import std.sync.*

public class DatasourceImpl <: Datasource {

    private var _optinos: Map<String, String>

    private var _closed: AtomicBool

    public DatasourceImpl() {
        _optinos = HashMap<String, String>()
        _closed = AtomicBool(false)
    }
    
    /*设置连接选项*/
    public override func setOption(key: String, value: String): Unit {
        _optinos.put(key, value)
    }

    /*返回一个可用的连接*/
    public override func connect(): Connection {
        checkResourceAvailability()
        return ConnectionImpl(_optinos)
    }

    public override func close() {
        checkResourceAvailability()
        _closed.store(true)
    }

    public override func isClosed(): Bool {
        return _closed.load()
    }

    private func checkResourceAvailability(){
        if(isClosed()){
            throw SqlException("The data Source has been closed")
        }
    } 
}
