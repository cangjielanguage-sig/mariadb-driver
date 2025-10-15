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
package mysql.xa

import std.collection.*
import mysql.connection.*

public class MySqlXaResouce <: Resource {

    private let connection: MySqlConnection

    public init(params: Map<String, String>) {
        this.connection = MySqlConnectionFactory.createAuthedConnection(params)
    }

    public func start(xid: MySqlXid, option!: ?StartOption = None): Unit {
        let builder = StringBuilder(100)
        builder.append("XA START ")
        appendXid(builder, xid)
        if(let Some(v) <- option) {
            match (v) {
                case Join => builder.append(" JOIN")
                case Resume => builder.append(" RESUME")
            }
        }
        connection.sendCommand(builder.toString())
    }

    public func end(xid: MySqlXid, suspend!: Bool = false): Unit {
        let builder = StringBuilder(100)
        builder.append("XA END ")
        appendXid(builder, xid)
        if(suspend){
            builder.append(" SUSPEND")
        }
        connection.sendCommand(builder.toString())
    }

    public func prepare(xid: MySqlXid): Unit {
        let builder = StringBuilder(100)
        builder.append("XA PREPARE ")
        appendXid(builder, xid)
        connection.sendCommand(builder.toString())
    }

    public func commit(xid: MySqlXid, onePhase!: Bool = false): Unit {
        let builder = StringBuilder(100)
        builder.append("XA COMMIT ")
        appendXid(builder, xid)
        if (onePhase) {
            builder.append(" ONE PHASE")
        }
        connection.sendCommand(builder.toString())
    }

    public func rollback(xid: MySqlXid): Unit {
        let builder = StringBuilder()
        builder.append("XA ROLLBACK ")
        appendXid(builder, xid)
        connection.sendCommand(builder.toString())
    }

    public func revocer(): Array<MySqlXid> {
        let result = connection.sendQuery("XA RECOVER")
        let xids = ArrayList<MySqlXid>()
        while (result.next()) {
            let formatId = result.getUInt64(1) ?? 1
            let gtridLength = result.getInt64(2) ?? 0
            let bqualLength = result.getInt64(3) ?? 0
            let data = result.getString(4) ?? ""
            let array = data.toArray()
            let gtrid = array.slice(0, gtridLength)
            let bqual = array.toArray().slice(gtridLength, bqualLength)
            let xid = MySqlXid(gtrid, branchQualifier: bqual , formatId: formatId)
            xids.add(xid)
        }
        return xids.toArray()
    }

    private func appendXid(builder: StringBuilder, xid: MySqlXid) {
        let gtrid = xid.globalTransactionId
        let btrid = xid.branchQualifier
        if (gtrid.size != 0) {
            builder.append(toHexStringWithPrefix(gtrid))
        }
        builder.append(',')
        if (btrid.size != 0) {
             builder.append(toHexStringWithPrefix(btrid))
        }
        builder.append(',')
        builder.append(xid.formatId)
    }

    public override func close(): Unit {
        connection.close()
    }

    public override func isClosed(): Bool {
        return connection.isClosed()
    }

}



public enum StartOption {

    | Join
    | Resume

}
