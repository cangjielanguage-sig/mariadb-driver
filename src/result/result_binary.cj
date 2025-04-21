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
protected package mysql.result

import std.io.*
import std.time.*
import std.convert.*
import std.collection.*
import std.math.numeric.*
import encoding.json.*
import mysql.protocol.*
import mysql.protocol.response.*

protected class BinaryResultSet <: ResultSet {
    
    private let columns: Array<ColumnDefinition>

    private let rows: Array<Array<?Array<Byte>>>

    private var currentRow: Int64

    protected BinaryResultSet(columns: Array<ColumnDefinition>, rows: Array<Array<?Array<Byte>>>) {
        this.columns = columns
        this.rows = rows
        this.currentRow = 0
    }

    public prop columnDefinitions: Array<ColumnDefinition> {
        get() {
            columns
        }
    }

    public func next(): Bool {
        if (currentRow >= rows.size) {
            return false
        } else {
            currentRow++
            return true
        }
    }

    public override func getBool(index: Int64): ?Bool {
        return Bool.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getInt8(index: Int64): ?Int8 {
        return Int8.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getUInt8(index: Int64): ?UInt8 {
        return UInt8.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getInt16(index: Int64): ?Int16 {
        return Int16.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getUInt16(index: Int64): ?UInt16 {
        return UInt16.fromBinary(metadata(index), getBinaryData(index))
    }

    @OverflowWrapping
    public override func getInt32(index: Int64): ?Int32 {
        return Int32.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getUInt32(index: Int64): ?UInt32 {
        return UInt32.fromBinary(metadata(index), getBinaryData(index))
    }

    @OverflowWrapping
    public override func getInt64(index: Int64): ?Int64 {
        return Int64.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getUInt64(index: Int64): ?UInt64 {
        return UInt64.fromBinary(metadata(index), getBinaryData(index))
    }


    public override func getFloat16(index: Int64): ?Float16 {
        return Float16.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getFloat32(index: Int64): ?Float32 {
        return Float32.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getFloat64(index: Int64): ?Float64 {
        return Float64.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getBigInt(index: Int64): ?BigInt {
        return BigInt.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getDecimal(index: Int64): ?Decimal {
        return Decimal.fromBinary(metadata(index), getBinaryData(index))

    }

    public override func getDate(index: Int64): ?DateTime {
        return DateTime.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getTime(index: Int64): ?DateTime {
        return DateTime.fromBinary(metadata(index), getBinaryData(index))
    }

    public func getDateTime(index: Int64): ?DateTime {
        return DateTime.fromBinary(metadata(index), getBinaryData(index))
    }

    public func getTimestamp(index: Int64): ?DateTime {
        return DateTime.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getInputStream(index: Int64): ?InputStream {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => return ByteBuffer(v)
        }
    }

    @OverflowWrapping
    public override func getString(index: Int64): ?String {
        return String.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func getArray(index: Int64): ?Array<Byte> {
        match (getBinaryData(index)) {
            case None => return None
            case Some(v) => 
                let columnType = metadata(index).columnType
                match (columnType) {
                    case String | VarString | Json | Enum | Set | TinyBlob | Blob | MediumBlob | LongBlob => 
                        return v
                    case _ => 
                        throw UnsupportedException("Unsupported database type ${columnType} convert to Array")
                }
        }
    }

    public override func getJsonValue(index: Int64): ?JsonValue {
        return JsonValue.fromBinary(metadata(index), getBinaryData(index))
    }

    public override func metadata(index: Int64): ColumnDefinition {
        return columns[index - 1]
    }

    private func getBinaryData(index: Int64): ?Array<Byte> {
        return this.rows[currentRow - 1][index - 1]
    }
}
