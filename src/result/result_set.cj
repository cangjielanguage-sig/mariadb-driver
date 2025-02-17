/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.result

import std.io.*
import std.time.*
import std.math.numeric.*
import encoding.json.*
import mysql.protocol.*
import mysql.protocol.response.*

protected interface ResultSet {

    prop columnDefinitions: Array<ColumnDefinition>

    func next(): Bool

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

    func metadata(index: Int64): ColumnDefinition

}
