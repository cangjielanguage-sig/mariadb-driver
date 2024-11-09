/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.*
import mysqlclient4cj.connection.*
import mysqlclient4cj.protocol.ColumnType

public class ColumnInfoImpl <: ColumnInfo {

    public ColumnInfoImpl(
        private let cname: String,
        private let ctype: String, 
        private let csize: Int64, 
        private let clength: Int64, 
        private let cscale: Int64,
        private let cnullable: Bool){}


    public override prop name: String {
        get() {
            return cname
        }
    }
    
    public override prop typeName: String {
        get() {
            return ctype
        }
    }

    public override prop displaySize: Int64 {
        get() {
            return csize
        }
    }

    public override prop length: Int64 {
        get() {
            return clength
        }
    }

    public override prop scale: Int64 {
        get() {
            return cscale
        }
    }

    public override prop nullable: Bool {
        get() {
            return cnullable
        }
    }
}

protected func toSqlType(filedType: ColumnType, isNotNull: Bool): String {
    if (isNotNull) {
        match (filedType) {
            case Tiny => "SqlByte"
            case Short => "SqlSmallInt"
            case Int24 => "SqlInteger"
            case Long => "SqlInteger"
            case LongLong => "SqlBigInt"
            case Float => "SqlReal"
            case Double => "SqlDouble"
            case NewDecimal => "SqlDecimal"
            case Date => "SqlDate"
            case Time => "SqlTime"
            case DateTime => "SqlTimestamp"
            case Timestamp => "SqlTimestamp"
            case Year => "SqlSmallInt"
            case TinyBlob => "SqlBlob"
            case Blob => "SqlBlob"
            case MediumBlob => "SqlBlob"
            case LongBlob => "SqlBlob"
            case String => "SqlChar"
            case VarString => "SqlVarchar"
            case Enum => "SqlChar"
            case Set => "SqlChar"
            case Json => "SqlJson"
        }
    } else {
        match (filedType) {
            case Tiny => "SqlNullableByte"
            case Short => "SqlNullableSmallInt"
            case Int24 => "SqlNullableInteger"
            case Long => "SqlNullableInteger"
            case LongLong => "SqlNullableBigInt"
            case Float => "SqlNullableReal"
            case Double => "SqlNullableDouble"
            case NewDecimal => "SqlNullableDecimal"
            case Date => "SqlNullableDate"
            case Time => "SqlNullableTime"
            case DateTime => "SqlNullableTimestamp"
            case Timestamp => "SqlNullableTimestamp"
            case Year => "SqlNullableSmallInt"
            case TinyBlob => "SqlNullableBlob"
            case Blob => "SqlNullableBlob"
            case MediumBlob => "SqlNullableBlob"
            case LongBlob => "SqlNullableBlob"
            case String => "SqlNullableChar"
            case VarString => "SqlNullableVarchar"
            case Enum => "SqlNullableChar"
            case Set => "SqlNullableChar"
            case Json => "SqlNullableJson"
        }
    }
}