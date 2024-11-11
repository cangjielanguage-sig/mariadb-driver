/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc

import std.time.DateTime
import std.io.InputStream
import std.math.numeric.BigInt
import std.math.numeric.Decimal
import encoding.json.JsonValue

public interface QueryResult <: Resource {

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

    func getDecimal(index: Int64): ?Decimal

    func getBigInt(index: Int64): ?BigInt

    func getDate(index: Int64): ?Date

    func getTime(index: Int64): ?Time

    func getDateTime(index: Int64): ?DateTime

    func getTimestamp(index: Int64): ?DateTime

    func getInputStream(index: Int64): ?InputStream

    func getString(index: Int64): ?String

    func getArray(index: Int64): ?Array<Byte>

    func getJsonValue(index: Int64): ?JsonValue

    func getBool(name: String): ?Bool

    func getInt8(name: String): ?Int8

    func getUInt8(name: String): ?UInt8

    func getInt16(name: String): ?Int16
    
    func getUInt16(name: String): ?UInt16

    func getInt32(name: String): ?Int32

    func getUInt32(name: String): ?UInt32

    func getInt64(name: String): ?Int64

    func getUInt64(name: String): ?UInt64

    func getFloat16(name: String): ?Float16

    func getFloat32(name: String): ?Float32

    func getFloat64(name: String): ?Float64

    func getDecimal(name: String): ?Decimal

    func getBigInt(name: String): ?BigInt

    func getDate(name: String): ?Date

    func getTime(name: String): ?Time

    func getDateTime(name: String): ?DateTime

    func getTimestamp(name: String): ?DateTime

    func getInputStream(name: String): ?InputStream

    func getString(name: String): ?String

    func getArray(name: String): ?Array<Byte>

    func getJsonValue(name: String): ?JsonValue
    
}