/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.result

import mysqlclient4cj.protocol.response.*

protected class ChangeResult {
    
    protected let effectRow: UInt64

    protected let lastInsertId: UInt64

    public ChangeResult(effectRow: UInt64, lastInsertId: UInt64) {
        this.effectRow = effectRow
        this.lastInsertId = lastInsertId
    }

}

protected class PrepareResult {

    protected let info: PrepareResposne

    protected let params: Array<ColumnDefinition>

    protected let columns: Array<ColumnDefinition>

    protected PrepareResult(info: PrepareResposne, parameters: Array<ColumnDefinition>, columns: Array<ColumnDefinition>){
        this.info = info
        this.params = parameters
        this.columns = columns
    }

    protected prop id: UInt32{
        get() {
            info.statementId
        }
    }

    protected prop paramDefinitions: Array<ColumnDefinition> {
        get() {
            params
        }
    }

    protected prop columnDefinitions: Array<ColumnDefinition> {
        get() {
            columns
        }
    }

}
