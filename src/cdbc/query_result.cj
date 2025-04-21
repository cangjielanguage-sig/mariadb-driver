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
import mysql.result.*

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

    public override func next(values: Array<SqlDbType>): Bool {
        checkResourceAvailability()
        if (!result.next()) {
            return false
        }
        for (i in 0..values.size) {
            match (values[i]) {
                case v: SqlBool => v.value = result.getBool(i).getOrThrow()
                case v: SqlByte => v.value = result.getInt8(i).getOrThrow()
                case v: SqlSmallInt => v.value = result.getInt16(i).getOrThrow()
                case v: SqlInteger => v.value = result.getInt32(i).getOrThrow()
                case v: SqlBigInt => v.value = result.getInt64(i).getOrThrow()
                case v: SqlReal => v.value = result.getFloat32(i).getOrThrow()
                case v: SqlDouble => v.value = result.getFloat64(i).getOrThrow()
                case v: SqlDecimal => v.value = result.getDecimal(i).getOrThrow()
                case v: SqlChar => v.value = result.getString(i).getOrThrow()
                case v: SqlVarchar => v.value = result.getString(i).getOrThrow()
                case v: SqlClob => v.value = result.getInputStream(i).getOrThrow()
                case v: SqlBlob => v.value = result.getInputStream(i).getOrThrow()
                case v: SqlDate => v.value = result.getDate(i).getOrThrow()
                case v: SqlTime => v.value = result.getTime(i).getOrThrow()
                case v: SqlTimeTz => v.value = result.getTime(i).getOrThrow()
                case v: SqlTimestamp => v.value = result.getTimestamp(i).getOrThrow()
                case v: SqlBinary => v.value = result.getArray(i).getOrThrow()
                case v: SqlVarBinary => v.value = result.getArray(i).getOrThrow()
                case v: SqlJson => v.value = result.getJsonValue(i).getOrThrow()

                case v: SqlNullableBool => v.value = result.getBool(i)
                case v: SqlNullableByte => v.value = result.getInt8(i)
                case v: SqlNullableSmallInt => v.value = result.getInt16(i)
                case v: SqlNullableInteger => v.value = result.getInt32(i)
                case v: SqlNullableBigInt => v.value = result.getInt64(i)
                case v: SqlNullableReal => v.value = result.getFloat32(i)
                case v: SqlNullableDouble => v.value = result.getFloat64(i)
                case v: SqlNullableDecimal => v.value = result.getDecimal(i)
                case v: SqlNullableChar => v.value = result.getString(i)
                case v: SqlNullableVarchar => v.value = result.getString(i)
                case v: SqlNullableClob => v.value = result.getInputStream(i)
                case v: SqlNullableBlob => v.value = result.getInputStream(i)
                case v: SqlNullableDate => v.value = result.getDate(i)
                case v: SqlNullableTime => v.value = result.getTime(i)
                case v: SqlNullableTimeTz => v.value = result.getTimestamp(i)
                case v: SqlNullableTimestamp => v.value = result.getTimestamp(i)
                case v: SqlNullableBinary => v.value = result.getArray(i)
                case v: SqlNullableVarBinary => v.value = result.getArray(i)
                case v: SqlNullableJson => v.value = result.getJsonValue(i)
                case _ => throw UnsupportedException("Unsupported SqlDbType")
            }
        }
        return true
    }

    public override func close() {
        checkResourceAvailability()
        closed = true
    }

    public override func isClosed(): Bool {
        return closed
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw SqlException("The database Connection has been closed")
        }
    }
}
