/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.packet

/*
 * Column Definition Flags
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/group__group__cs__column__definition__flags.html
 */
protected enum ColumnFlag {
    
    | NotNull
    | PrimaryKey
    | UniqueKey
    | MultipleKey
    | Blob
    | Unsigned
    | ZeroFill
    | Binary
    | Enum
    | AutoIncrement
    | Timestamp
    | Set
    | NoDefaultValue
    | OnUpdateNow
    | PartKey
    | Num

    internal func value(): UInt16{
        match (this) {
            case NotNull => return 1
            case PrimaryKey => return 2
            case UniqueKey => return 4
            case MultipleKey => return 8
            case Blob => return 16
            case Unsigned => 32
            case ZeroFill => 64
            case Binary => 128
            case Enum => 256
            case AutoIncrement => 512
            case Timestamp => 1024
            case Set => 2048
            case NoDefaultValue => 4096
            case OnUpdateNow => 8192
            case PartKey => 16384
            case Num => 32768
        }
    }
}