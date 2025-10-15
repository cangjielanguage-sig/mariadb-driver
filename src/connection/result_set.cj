/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
protected package mysql.connection

import std.io.*
import std.time.*
import std.math.numeric.*
import mysql.protocol.*

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

    func getDateTime(index: Int64): ?DateTime

    func getInputStream(index: Int64): ?InputStream

    func getString(index: Int64): ?String

    func getArray(index: Int64): ?Array<Byte>

    func metadata(index: Int64): ColumnDefinition

}
