/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc

import std.time.DateTime
import std.math.numeric.{Decimal, BigInt}
import std.io.InputStream
import encoding.json.JsonValue
import std.collection.ArrayList

public interface Statement <: Resource {

    func query(params: Array<Any>): QueryResult

    func update(params: Array<Any>): UpdateResult

    func query(): QueryResult

    func update(): UpdateResult

    func setNull(paramIndex: Int64): Unit

    func setString(paramIndex: Int64, value: String): Unit

    func setBool(paramIndex: Int64, value: Bool): Unit

    func setInt8(paramIndex: Int64, value: Int8): Unit

    func setUInt8(paramIndex: Int64, value: UInt8): Unit

    func setInt16(paramIndex: Int64, value: Int16): Unit

    func setUInt16(paramIndex: Int64, value: UInt16): Unit

    func setInt32(paramIndex: Int64, value: Int32): Unit

    func setUInt32(paramIndex: Int64, value: UInt32): Unit

    func setInt64(paramIndex: Int64, value: Int64): Unit

    func setUInt64(paramIndex: Int64, value: UInt64): Unit

    func setFloat16(paramIndex: Int64, value: Float16): Unit

    func setFloat32(paramIndex: Int64, value: Float16): Unit

    func setFloat64(paramIndex: Int64, value: Float16): Unit

    func setBigInt(paramIndex: Int64, value: BigInt): Unit

    func setDecimal(paramIndex: Int64, value: Decimal): Unit

    func setDate(paramIndex: Int64, value: Date): Unit

    func setTime(paramIndex: Int64, value: Time): Unit

    func setDateTime(paramIndex: Int64, value: DateTime): Unit

    func setTimestamp(paramIndex: Int64, value: DateTime): Unit

    func setArray(paramIndex: Int64, value: Array<Byte>): Unit

    func setInputStream(paramIndex: Int64, value: InputStream): Unit

    func setJson(paramIndex: Int64, valuel: JsonValue): Unit 
}

