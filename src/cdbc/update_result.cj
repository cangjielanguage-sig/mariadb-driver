/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.cdbc

import std.database.sql.*

public class UpdateResultImpl <: UpdateResult{
    
    private var _rowCount: Int64 = 0
    
    private var _lastInsertId: Int64 = 0

    public UpdateResultImpl(effectRowCount: Int64, lastInsertId: Int64){
        _rowCount = effectRowCount
        _lastInsertId = lastInsertId
    }
    
    /*获取执行 Insert, Update, Delete 语句影响的行数*/
    override public prop rowCount: Int64{
        get() {
            return _rowCount
        }
    }

    /*获取执行 Insert 语句自动生成的最后 row ID ，如果不支持则为 0*/
    override public prop lastInsertId: Int64{
        get() {
            return _lastInsertId
        }
    }


}