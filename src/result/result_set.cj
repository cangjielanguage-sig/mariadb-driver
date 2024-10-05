/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.result

import std.time.*
import std.convert.*
import std.io.*
import encoding.json.*
import cjmd.protocol.*
import std.math.numeric.{Decimal, BigInt}

protected interface ResultSet {

    prop rowSize: Int64

    prop columnSize: Int64

    func next(): Bool

    func getIndexByName(name: String): Int64

    func getBool(index: Int64): ?Bool

    func getInt8(index: Int64): ?Int8

    func getUInt8(index: Int64): ?UInt8

    func getInt16(index: Int64): ?Int16
    
    func getUInt16(index: Int64): ?UInt16

    func getInt32(index: Int64): ?Int32

    func getUInt32(index: Int64): ?UInt32

    func getInt64(index: Int64): ?Int64

    func getUInt64(index: Int64): ?UInt64

    func getFloat16(index: Int64): ?Float16

    func getFloat32(index: Int64): ?Float32

    func getFloat64(index: Int64): ?Float64

    func getBigInt(index: Int64): ?BigInt

    func getDecimal(index: Int64): ?Decimal

    func getDate(index: Int64): ?DateTime

    func getTime(index: Int64): ?DateTime

    func getDateTime(index: Int64): ?DateTime

    func getTimestamp(index: Int64): ?DateTime

    func getInputStream(index: Int64): ?InputStream

    func getString(index: Int64): ?String

    func getArray(index: Int64): ?Array<Byte>

    func getJsonValue(index: Int64): ?JsonValue

    func getFieldType(index: Int64): ColumnType

    func getFieldName(index: Int64): String

    func getFieldDecimal(index: Int64): Byte

    func getFieldIsNotNull(index: Int64): Bool

    func getFieldIsUnsigned(index: Int64): Bool

    func getFieldLength(index: Int64): UInt32

    func getFieldCharset(index: Int64): Charset
}
