/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.result

import std.time.*
import std.convert.*
import std.io.*
import encoding.json.*
import cjmd.protocol.*

protected class ChangeResult {
    
    private var _effectRow: UInt64

    private var _firstInsertId: UInt64

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

    private var info: PrepareResposne

    private var parameters: Array<ColumnDefinition>

    private var columns: Array<ColumnDefinition>

    protected PrepareResult(info: PrepareResposne, parameters: Array<ColumnDefinition>, columns: Array<ColumnDefinition>){
        this.info = info
        this.parameters = parameters
        this.columns = columns
    }

    protected prop id: UInt32{
        get() {
            info.statementId
        }
    }

    protected prop parameterDefinition: Array<ColumnDefinition> {
        get() {
            parameters
        }
    }

}
