/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysql.cdbc

import std.database.sql.UpdateResult

public class UpdateResultImpl <: UpdateResult{
    
    private var effectRows: Int64 = 0
    
    private var lastIndex: Int64 = 0

    public UpdateResultImpl(effectRowCount: Int64, lastInsertId: Int64){
        this.effectRows= effectRowCount
        this.lastIndex = lastInsertId
    }
    
    /*获取执行 Insert, Update, Delete 语句影响的行数*/
    override public prop rowCount: Int64{
        get() {
            return effectRows
        }
    }

    /*获取执行 Insert 语句自动生成的最后 row ID ，如果不支持则为 0*/
    override public prop lastInsertId: Int64{
        get() {
            return lastIndex
        }
    }


}