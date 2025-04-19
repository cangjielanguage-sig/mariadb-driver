/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.xa

import std.collection.*
import mysql.util.*
import mysql.protocol.*
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
