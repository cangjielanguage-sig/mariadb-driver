/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysql.cdbc

import std.database.sql.*
import std.convert.Parsable
import std.time.DateTime
import std.sync.ReentrantMutex
import std.sync.AtomicBool
import std.collection.ArrayList
import mysql.result.ResultSet

public class QueryResultImpl <: QueryResult {
    
    private var infos: Array<ColumnInfo>

    private var result: ResultSet

    private var resultSetMutext: ReentrantMutex = ReentrantMutex()

    private var closed: AtomicBool = AtomicBool(false)

    public override prop columnInfos: Array<ColumnInfo> {
        get() {
            return infos
        }
    }

    protected QueryResultImpl(result: ResultSet) {
        this.result = result
        let arrayList = ArrayList<ColumnInfo>()
        for(i in result.columnDefinitions){
            let info = ColumnInfoImpl(i)
            arrayList.append(info)
        }
        this.infos = arrayList.toArray()
    }   

    /*向后移动一行，必须先调用一次 next 才能移动到第一行，第二次调用移动到第二行，依此类推。当返回 true 时，驱动会在 values 中填入行数据；当返回 false 时结束，且不会修改 values 的内容。*/
    public override func next(values: Array<SqlDbType>): Bool {
        checkResourceAvailability()
        synchronized(resultSetMutext){
            if(!result.next()){
                return false
            }
            for (i in 1..= values.size) {
                match (values[i - 1]) {
                    case v: SqlBool => v.value = result.getBool(i).getOrThrow()
                    case v: SqlByte => v.value = result.getInt8(i).getOrThrow()
                    case v: SqlSmallInt => v.value = result.getInt16(i).getOrThrow()
                    case v: SqlInteger => v.value =result.getInt32(i).getOrThrow()
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
                    case v: SqlNullableClob => v.value =  result.getInputStream(i)
                    case v: SqlNullableBlob => v.value = result.getInputStream(i)
                    case v: SqlNullableDate => v.value = result.getDate(i)
                    case v: SqlNullableTime => v.value = result.getTime(i)
                    case v: SqlNullableTimeTz => v.value = result.getTimestamp(i)
                    case v: SqlNullableTimestamp => v.value = result.getTimestamp(i)
                    case v: SqlNullableBinary => v.value =result.getArray(i)
                    case v: SqlNullableVarBinary => v.value =result.getArray(i)
                    case v: SqlNullableJson => v.value = result.getJsonValue(i)
                    case _ => throw UnsupportedException("Unsupported SqlDbType")
                }
            }
            return true
        }
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
            throw SqlException("The database Connection has been closed")
        }
    }

}
