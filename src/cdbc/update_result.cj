/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.cdbc

import std.database.sql.*

public class UpdateResultImpl <: UpdateResult {
    
    private var effectRows: Int64 = 0
    
    private var lastIndex: Int64 = 0

    public UpdateResultImpl(effectRowCount: Int64, lastInsertId: Int64){
        this.effectRows= effectRowCount
        this.lastIndex = lastInsertId
    }

    override public prop rowCount: Int64{
        get() {
            return effectRows
        }
    }

    override public prop lastInsertId: Int64{
        get() {
            return lastIndex
        }
    }


}