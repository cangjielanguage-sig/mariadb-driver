/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.*
import encoding.json.*

public class SqlJson <: SqlDbType{

    private let _name: String = "SqlJson"

    private var _value: JsonValue

    public SqlJson(value: JsonValue){
        _value = value
    }
    public prop name: String{
        get() {
            _name
        }
    }
    public mut prop value: JsonValue{
        get() {
            _value
        }
        set(value) {
            _value = value
        }
    }
}

public class SqlNullableJson <: SqlNullableDbType{

    private let _name: String = "SqlNullableJson"
    
    private var _value: ?JsonValue

    public SqlNullableJson(value: ?JsonValue){
        _value = value
    }
    public prop name: String{
        get() {
            _name
        }
    }
    public mut prop value: ?JsonValue{
        get() {
            _value
        }
        set(value) {
            _value = value
        }
    }
}
