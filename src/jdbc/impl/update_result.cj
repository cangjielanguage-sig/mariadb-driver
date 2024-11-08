/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl

import mysqlclient4cj.jdbc.UpdateResult

public class UpdateResultImpl <: UpdateResult {

    private let effectRows: Int64
    
    private let lastIndex: Int64

    public UpdateResultImpl(effectRows: Int64, lastIndex: Int64){
        this.effectRows = effectRows
        this.lastIndex = lastIndex
    }


    public override prop lastInsertId: Int64 {
        get() {
            lastIndex
        }
    }

    public override prop effectRow: Int64 {
        get() {
            effectRows
        }
    }

}