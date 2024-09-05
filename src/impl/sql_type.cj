/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.impl

import std.database.sql.*
import encoding.json.*

public class SqlJson <: SqlDbType{

    private let _name: String = "SqlJSON"

    private var _value: JsonObject

    public SqlJson(value: JsonObject){
        _value = value
    }
    public prop name: String{
        get() {
            _name
        }
    }
    public mut prop value: JsonObject{
        get() {
            _value
        }
        set(value) {
            _value = value
        }
    }
}

public class SqlNullableJson <: SqlNullableDbType{

    private let _name: String = "SqlNullableJSON"
    
    private var _value: ?JsonObject

    public SqlNullableJson(value: ?JsonObject){
        _value = value
    }
    public prop name: String{
        get() {
            _name
        }
    }
    public mut prop value: ?JsonObject{
        get() {
            _value
        }
        set(value) {
            _value = value
        }
    }
}
