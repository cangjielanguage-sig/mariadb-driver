/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package mysql.cdbc

import std.database.sql.*
import encoding.json.*

public class SqlJson <: SqlDbType {

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
