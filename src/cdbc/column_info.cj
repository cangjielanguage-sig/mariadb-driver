/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.*
import mysqlclient4cj.connection.*
import mysqlclient4cj.protocol.*

public class ColumnInfoImpl <: ColumnInfo {

    private var _name: String

    private var _type: String

    private var _displaySize: Int64

    private var _length: Int64

    private var _scale: Int64

    private var _nullable: Bool

    public ColumnInfoImpl(fieldName: String,
                          fieldType: String, 
                          displaySize: Int64, 
                          length: Int64, 
                          scale: Int64,
                          nullable: Bool) {
        _name = fieldName
        _type = fieldType
        _displaySize = displaySize
        _length = length
        _scale = scale
        _nullable = nullable
    }

    public override prop name: String {
        get() {
            return _name
        }
    }
    
    public override prop typeName: String {
        get() {
            return _type
        }
    }

    public override prop displaySize: Int64 {
        get() {
            return _displaySize
        }
    }

    public override prop length: Int64 {
        get() {
            return _length
        }
    }

    public override prop scale: Int64 {
        get() {
            return _scale
        }
    }

    public override prop nullable: Bool {
        get() {
            return _nullable
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
            case Date => "SqlNullableData"
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