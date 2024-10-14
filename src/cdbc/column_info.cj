/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.ColumnInfo
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

// protected func getSqlType(filedType: ColumnType, isNotNull: Bool): String {
//     if (isNotNull) {
//         match (filedType) {
//             //case Decimal => "SqlDouble"
//             case Tiny => "SqlByte"
//             case Short => "SqlSmallInt"
//             case Long => "SqlInteger"
//             case Float => "SqlReal"
//             case Double => "SqlDouble"
//             case Null => "SqlNullableDbType"
//             case Timestamp => "SqlTimestamp"
//             case LongLong => "SqlBigInt"
//             case Int24 => "SqlInteger"
//             case Date => "SqlDate"
//             case Time => "SqlTime"
//             case DateTime => "SqlTimestamp"
//             case Year => "SqlSmallInt"
//             //case NewDate => "SqlDate"
//             //case Varchar => "SqlVarchar"
//             //case Bit => "SqlBinary"
//             //case Timestamp2 => "SqlTimestamp"
//             //case DateTime2 => "SqlTime"
//             //case _Bool => "SqlBool"
//             case NewDecimal => "SqlDouble"
//             case Enum => "SqlChar"
//             case Set => "SqlChar"
//             case TinyBlob => "SqlBlob"
//             case MediumBlob => "SqlBlob"
//             case LongBlob => "SqlBlob"
//             case Blob => "SqlBlob"
//             case VarString => "SqlVarchar"
//             case String => "SqlChar"
//             //case Geometry => "SqlVarchar"
//             //case Time2 => "SqlTime"
//             case Json => "SqlJson"
//         }
//     } else {
//         match (filedType) {
//             //case Decimal => "SqlNullableDouble"
//             case Tiny => "SqlNullableByte"
//             case Short => "SqlNullableSmallInt"
//             case Long => "SqlNullableInteger"
//             case Float => "SqlNullableReal"
//             case Double => "SqlNullableDouble"
//             case Timestamp => "SqlNullableTimestamp"
//             case LongLong => "SqlNullableBigInt"
//             case Int24 => "SqlNullableInteger"
//             case Date => "SqlNullableVarchar"
//             case Time => "SqlNullableVarchar"
//             case DateTime => "SqlNullableTimestamp"
//             case Year => "SqlNullableSmallInt"
//             //case NewDate => "SqlNullableVarchar"
//             //case Varchar => "SqlNullableVarchar"
//             //case Bit => "SqlNullableBinary"
//             //case Timestamp2 => "SqlNullableTimestamp"
//             //case DateTime2 => "SqlNullableTimestamp"
//             //case _Bool => "SqlNullableBool"
//             case NewDecimal => "SqlNullableDouble"
//             case Enum => "SqlNullableChar"
//             case Set => "SqlNullableChar"
//             case TinyBlob => "SqlNullableBlob"
//             case MediumBlob => "SqlNullableBlob"
//             case LongBlob => "SqlNullableBlob"
//             case Blob => "SqlNullableBlob"
//             case VarString => "SqlNullableVarchar"
//             case String => "SqlNullableChar"
//             case Null => "SqlNullableDbType"
//             //case Geometry => "SqlNullableVarchar"
//             //case Time2 => "SqlNullableVarchar"
//             case Json => "SqlNullableJson"
//         }
//     }
// }