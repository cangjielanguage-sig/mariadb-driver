/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc


import std.sync.AtomicBool
import std.collection.HashMap
import std.database.sql.Datasource
import std.database.sql.Connection
import std.database.sql.SqlException

public class DatasourceImpl <: Datasource {

    private var optinos: HashMap<String, String>

    private var closed: AtomicBool

    public DatasourceImpl() {
        optinos = HashMap<String, String>()
        closed = AtomicBool(false)
    }
    
    /*设置连接选项*/
    public override func setOption(key: String, value: String): Unit {
        optinos.put(key, value)
    }

    /*返回一个可用的连接*/
    public override func connect(): Connection {
        checkResourceAvailability()
        return ConnectionImpl(optinos)
    }

    public override func close() {
        checkResourceAvailability()
        closed.store(true)
    }

    public override func isClosed(): Bool {
        return closed.load()
    }

    private func checkResourceAvailability(){
        if(isClosed()){
            throw SqlException("The data Source has been closed")
        }
    } 
}
