/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.impl

import std.database.sql.*
import cjmd.connection.*
import cjmd.result.*
import std.convert.*
import std.time.*
import std.io.*
import encoding.json.*
import std.sync.*
import std.math.min
import std.collection.ArrayList

public class QueryResultImpl <: QueryResult {
    
    private var _columnInfos: Array<ColumnInfo>

    private var _result: ResultSet

    private var _resultSetMutext: ReentrantMutex = ReentrantMutex()

    private var _closed: AtomicBool = AtomicBool(false)

    public override prop columnInfos: Array<ColumnInfo> {
        get() {
            return _columnInfos
        }
    }

    public QueryResultImpl(result: ResultSet) {
        _result = result
        _columnInfos = []
        var arrayList = ArrayList<ColumnInfo>()
        for(i in 0.._result.columnSize){
            var name = _result.getFieldName(i + 1)
            var fieldType = _result.getFieldType(i + 1)
            var notNull = _result.getFieldIsNotNull(i + 1)
            var length = _result.getFieldLength(i + 1)
            var decimal = _result.getFieldDecimal(i + 1)
            var info = ColumnInfoImpl(name, getSqlType(fieldType, notNull), Int64(length), Int64(length), Int64(decimal), !notNull)
            arrayList.append(info)
        }
        _columnInfos = arrayList.toArray()
    }   

    /*向后移动一行，必须先调用一次 next 才能移动到第一行，第二次调用移动到第二行，依此类推。当返回 true 时，驱动会在 values 中填入行数据；当返回 false 时结束，且不会修改 values 的内容。*/
    public override func next(values: Array<SqlDbType>): Bool {
        checkResourceAvailability()
        synchronized(_resultSetMutext){
            if(!_result.next()){
                return false
            }
            for (i in 1..=min(values.size,_result.columnSize)) {
                match (values[i - 1]) {
                    case v: SqlBool => v.value = _result.getBool(i).getOrThrow()
                    case v: SqlByte => v.value = _result.getInt8( i).getOrThrow()
                    case v: SqlSmallInt => v.value = _result.getInt16(i).getOrThrow()
                    case v: SqlInteger => v.value =_result.getInt32(i).getOrThrow()
                    case v: SqlBigInt => v.value = _result.getInt64(i).getOrThrow()
                    case v: SqlReal => v.value = _result.getFloat32(i).getOrThrow()
                    case v: SqlDouble => v.value = _result.getFloat64(i).getOrThrow()
                    case v: SqlDecimal => v.value = _result.getDecimal(i).getOrThrow()
                    case v: SqlChar => v.value = _result.getString(i).getOrThrow()
                    case v: SqlVarchar => v.value = _result.getString(i).getOrThrow()
                    case v: SqlClob => v.value = _result.getInputStream(i).getOrThrow()
                    case v: SqlBlob => v.value = _result.getInputStream(i).getOrThrow()
                    case v: SqlDate => v.value = _result.getDate(i).getOrThrow()
                    case v: SqlTime => v.value = _result.getTime(i).getOrThrow()
                    case v: SqlTimeTz => v.value = _result.getTime(i).getOrThrow()
                    case v: SqlTimestamp => v.value = _result.getTimestamp(i).getOrThrow()
                    case v: SqlBinary => v.value = _result.getArray(i).getOrThrow()
                    case v: SqlVarBinary => v.value = _result.getArray(i).getOrThrow()
                    case v: SqlJson => v.value = _result.getJsonValue(i).getOrThrow()
                    
                    case v: SqlNullableBool => v.value = _result.getBool(i)
                    case v: SqlNullableByte => v.value = _result.getInt8(i)
                    case v: SqlNullableSmallInt => v.value = _result.getInt16(i)
                    case v: SqlNullableInteger => v.value = _result.getInt32(i)
                    case v: SqlNullableBigInt => v.value = _result.getInt64(i)
                    case v: SqlNullableReal => v.value = _result.getFloat32(i)
                    case v: SqlNullableDouble => v.value = _result.getFloat64(i)
                    case v: SqlNullableDecimal => v.value = _result.getDecimal(i)
                    case v: SqlNullableChar => v.value = _result.getString(i)
                    case v: SqlNullableVarchar => v.value = _result.getString(i)
                    case v: SqlNullableClob => v.value =  _result.getInputStream(i)
                    case v: SqlNullableBlob => v.value = _result.getInputStream(i)
                    case v: SqlNullableDate => v.value = _result.getDate(i)
                    case v: SqlNullableTime => v.value = _result.getTime(i)
                    case v: SqlNullableTimeTz => v.value = _result.getTimestamp(i)
                    case v: SqlNullableTimestamp => v.value = _result.getTimestamp(i)
                    case v: SqlNullableBinary => v.value =_result.getArray(i)
                    case v: SqlNullableVarBinary => v.value =_result.getArray(i)
                    case v: SqlNullableJson => v.value = _result.getJsonValue(i)
                    case _ => throw UnsupportedException("Unsupported SqlDbType")
                }
            }
            return true
        }
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
            throw SqlException("The database Connection has been closed")
        }
    }

}
