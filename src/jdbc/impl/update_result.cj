/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl

import mysqlclient4cj.jdbc.UpdateResult

public class UpdateResultImpl <: UpdateResult {

    private var _effectRow: Int64 = 0
    
    private var _lastInsertId: Int64 = 0

    public UpdateResultImpl(effectRowCount: Int64, lastInsertId: Int64){
        _effectRow = effectRowCount
        _lastInsertId = lastInsertId
    }


    public override prop lastInsertId: Int64 {
        get() {
            _lastInsertId
        }
    }

    public override prop effectRow: Int64 {
        get() {
            _effectRow
        }
    }

}