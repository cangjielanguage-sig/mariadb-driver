/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.result

import mysqlclient4cj.protocol.response.*

protected class ChangeResult {
    
    private let _effectRow: UInt64

    private let _firstInsertId: UInt64

    public ChangeResult(effectRow: UInt64, firstInsertId: UInt64) {
        _effectRow = effectRow
        _firstInsertId = firstInsertId
    }

    public prop effectRow: UInt64 {
        get() {
            _effectRow
        }
    }

    public prop firstInsertId: UInt64 {
        get() {
            _firstInsertId
        }
    }
}

protected class PrepareResult {

    private let _info: PrepareResposne

    private let _parames: Array<ColumnDefinition>

    private let _columns: Array<ColumnDefinition>

    protected PrepareResult(info: PrepareResposne, parameters: Array<ColumnDefinition>, columns: Array<ColumnDefinition>){
        _info = info
        _parames = parameters
        _columns = columns
    }

    protected prop id: UInt32{
        get() {
            _info.statementId
        }
    }

    protected prop paramDefinitions: Array<ColumnDefinition> {
        get() {
            _parames
        }
    }

    protected prop columnDefinitions: Array<ColumnDefinition> {
        get() {
            _columns
        }
    }

}
