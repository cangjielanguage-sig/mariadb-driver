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
        return getOrNull<T>(index) ?? throw NoneValueException()
    }

    public func getOrNull<T>(index: Int): ?T {
        checkResource()
        if (index <= 0) {
            throw IllegalArgumentException("The index must be greater than 0")
        }
        let instance: ?T = None
        //var value: Any
        let value = 
        match (instance) {
            case v: ?Bool => result.getBool(index)
            case v: ?Int8 => result.getInt8(index)
            case v: ?Int16 => result.getInt16(index)
            case v: ?Int32 => result.getInt32(index)
            case v: ?Int64 => result.getInt64(index)
            case v: ?UInt8 => result.getUInt8(index)
            case v: ?UInt16 => result.getUInt16(index)
            case v: ?UInt32 => result.getUInt32(index)
            case v: ?UInt64 => result.getUInt64(index)
            case v: ?Float16 => result.getFloat16(index)
            case v: ?Float32 => result.getFloat32(index)
            case v: ?Float64 => result.getFloat64(index)
            case v: ?String => result.getString(index)
            case v: ?Array<Byte> => result.getArray(index)
            case v: ?InputStream => result.getInputStream(index)
            case v: ?DateTime => result.getDateTime(index)
            case v: ?BigInt => result.getBigInt(index)
            case v: ?Decimal => result.getDecimal(index)
            case _ => throw UnsupportedException("unsupport type")
        }
        return (value as ?T) ?? throw IllegalStateException()
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
