/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl

import std.collection.Map
import std.collection.HashMap
import mysqlclient4cj.jdbc.Connection
import mysqlclient4cj.jdbc.Datasource

public class DatasourceImpl <: Datasource  {

    private var options: Map<String, String>

    public init(){
        this.options = HashMap<String,String>()
    }

    public init(options: Map<String, String>){
        this.options = options
    }

    public override func connect(): Connection {
        return ConnectionImpl(options)
    }

    public override func setOption(key: String, value: String): Unit {
        options.put(key, value)
    }

    override public func close(){
    }
    
    override public func isClosed(): Bool{
        return true
    }

}