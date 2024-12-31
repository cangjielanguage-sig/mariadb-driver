/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysql.cdbc

import std.database.sql.SqlDbType
import std.database.sql.SqlNullableDbType
import encoding.json.JsonValue

public class SqlJson <: SqlDbType{

    private let typeName: String = "SqlJson"

    private var store: JsonValue

    public SqlJson(value: JsonValue){
        store = value
    }
    public prop name: String{
        get() {
            typeName
        }
    }
    public mut prop value: JsonValue{
        get() {
            store
        }
        set(value) {
            store = value
        }
    }
}

public class SqlNullableJson <: SqlNullableDbType{

    private let typeName: String = "SqlNullableJson"
    
    private var store: ?JsonValue

    public SqlNullableJson(value: ?JsonValue){
        store = value
    }
    public prop name: String{
        get() {
            typeName
        }
    }
    public mut prop value: ?JsonValue{
        get() {
            store
        }
        set(value) {
            store = value
        }
    }
}
