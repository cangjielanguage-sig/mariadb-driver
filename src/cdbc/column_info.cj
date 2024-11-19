/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.*
import mysqlclient4cj.protocol.*
import mysqlclient4cj.protocol.response.*

public class ColumnInfoImpl <: ColumnInfo {

    private let colName: String

    private let colType: String

    private let colSize: Int64

    private let colLength: Int64

    private let colScale: Int64

    private let colNullable: Bool

    protected init(definition: ColumnDefinition) {
        this.colName = definition.name
        this.colType = sqlType(definition)
        this.colSize = Int64(definition.columnLength)
        this.colLength = Int64(definition.columnLength)
        this.colScale = Int64(definition.decimals)
        this.colNullable = !definition.hasFlag(NotNull)
    }

    public override prop name: String {
        get() {
            return colName
        }
    }

    public override prop typeName: String {
        get() {
            return colType
        }
    }

    public override prop displaySize: Int64 {
        get() {
            return colSize
        }
    }

    public override prop length: Int64 {
        get() {
            return colLength
        }
    }

    public override prop scale: Int64 {
        get() {
            return colScale
        }
    }

    public override prop nullable: Bool {
        get() {
            return colNullable
        }
    }
}

private func sqlType(definition: ColumnDefinition): String {
    if (definition.hasFlag(NotNull)) {
        match (definition.columnType) {
            case Tiny where definition.columnLength == 1 => "SqlBool"
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
        match (definition.columnType) {
            case Tiny where definition.columnLength == 1 => "SqlNullableBool"
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
