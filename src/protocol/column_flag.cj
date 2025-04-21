/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mysql.protocol

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

    internal func value(): UInt16 {
        match (this) {
            case NotNull => 1
            case PrimaryKey => 2
            case UniqueKey => 4
            case MultipleKey => 8
            case Blob => 16
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