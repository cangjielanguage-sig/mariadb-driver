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

import std.collection.*
import std.database.sql.*
import std.io.*
import std.time.*
import std.math.numeric.*
import mysql.connection.*

public class QueryResultImpl <: QueryResult {

    private var infos: Array<ColumnInfo>

    private var result: ResultSet

    private var closed: Bool

    public override prop columnInfos: Array<ColumnInfo> {
        get() {
            return infos
        }
    }

    protected QueryResultImpl(result: ResultSet) {
        this.result = result
        let arrayList = ArrayList<ColumnInfo>()
        for (i in result.columnDefinitions) {
            let info = ColumnInfoImpl(i)
            arrayList.add(info)
        }
        this.infos = arrayList.toArray()
        closed = false
    }

    public func next(): Bool {
        return result.next()
    }

    public func get<T>(index: Int): T {
        checkResource()
        if(index <= 0) {
            throw IllegalArgumentException("The index must be greater than 0")
        }
        let instance: Option<T> = None
        match (instance) {
            case v: Option<Bool> => (result.getBool(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Int8> => (result.getInt8(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Int16> => (result.getInt16(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Int32> => (result.getInt32(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Int64> => (result.getInt64(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<UInt8> => (result.getUInt8(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<UInt16> => (result.getUInt16(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<UInt32> => (result.getUInt32(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<UInt64> => (result.getUInt64(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Float16> => (result.getFloat16(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Float32> => (result.getFloat32(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Float64> => (result.getFloat64(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<String> => (result.getString(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Array<Byte>> => (result.getArray(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<InputStream> => (result.getInputStream(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<DateTime> => (result.getDateTime(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<BigInt> => (result.getBigInt(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case v: Option<Decimal> => (result.getDecimal(index) as Option<T> ?? throw Exception()) ?? throw Exception()
            case _ => throw UnsupportedException("unsupport type")
        }
    }

    public func getOrNull<T>(index: Int): ?T {
        checkResource()
        if(index <= 0) {
            throw IllegalArgumentException("The index must be greater than 0")
        }
        let instance: Option<T> = None
        match (instance) {
            case v: Option<Bool> => result.getBool(index) as Option<T> ?? throw Exception()
            case v: Option<Int8> => result.getInt8(index) as Option<T> ?? throw Exception()
            case v: Option<Int16> => result.getInt16(index) as Option<T> ?? throw Exception()
            case v: Option<Int32> => result.getInt32(index) as Option<T> ?? throw Exception()
            case v: Option<Int64> => result.getInt64(index) as Option<T> ?? throw Exception()
            case v: Option<UInt8> => result.getUInt8(index) as Option<T> ?? throw Exception()
            case v: Option<UInt16> => result.getUInt16(index) as Option<T> ?? throw Exception()
            case v: Option<UInt32> => result.getUInt32(index) as Option<T> ?? throw Exception()
            case v: Option<UInt64> => result.getUInt64(index) as Option<T> ?? throw Exception()
            case v: Option<Float16> => result.getFloat16(index) as Option<T> ?? throw Exception()
            case v: Option<Float32> => result.getFloat32(index) as Option<T> ?? throw Exception()
            case v: Option<Float64> => result.getFloat64(index) as Option<T> ?? throw Exception()
            case v: Option<String> => result.getString(index) as Option<T> ?? throw Exception()
            case v: Option<Array<Byte>> => result.getArray(index) as Option<T> ?? throw Exception()
            case v: Option<InputStream> => result.getInputStream(index) as Option<T> ?? throw Exception()
            case v: Option<DateTime> => result.getDateTime(index) as Option<T> ?? throw Exception()
            case v: Option<BigInt> => result.getBigInt(index) as Option<T> ?? throw Exception()
            case v: Option<Decimal> => result.getDecimal(index) as Option<T> ?? throw Exception()
            case _ => throw UnsupportedException("unsupport type")
        }
    }

    @Deprecated
    public override func next(_: Array<SqlDbType>): Bool {
        throw UnsupportedException("Deprecated method")
    }

    public override func close() {
        checkResource()
        closed = true
    }

    public override func isClosed(): Bool {
        return closed
    }

    private func checkResource() {
        if (isClosed()) {
            throw SqlException("The database Connection has been closed")
        }
    }
}
