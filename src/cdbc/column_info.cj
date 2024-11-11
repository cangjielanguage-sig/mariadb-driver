/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.ColumnInfo
import mysqlclient4cj.protocol.ColumnType
import mysqlclient4cj.protocol.response.ColumnDefinition

public class ColumnInfoImpl <: ColumnInfo {
    
    private let definition: ColumnDefinition

    protected init(definition: ColumnDefinition) {
        this.definition = definition
    }

    public override prop name: String {
        get() {
            return definition.name
        }
    }

    public override prop typeName: String {
        get() {
            if (!nullable) {
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
    }

    public override prop displaySize: Int64 {
        get() {
            return Int64(definition.columnLength)
        }
    }

    public override prop length: Int64 {
        get() {
            return Int64(definition.columnLength)
        }
    }

    public override prop scale: Int64 {
        get() {
            return Int64(definition.decimals)
        }
    }

    public override prop nullable: Bool {
        get() {
            return !definition.hasFlag(NotNull)
        }
    }
}
