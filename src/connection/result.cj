/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
protected package mariadb.connection

import mariadb.protocol.*

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

    protected prop id: UInt32 {
        get() {
            info.statementId
        }
    }

}
