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
protected package mariadb.protocol

import std.io.*

protected class ExecuteCommand <: Command {

    private let statementId: UInt32

    private let flags: CursorType

    private let iterationCount: UInt32

    private let parameterCount: UInt64

    private let nullBitMap: Array<Byte>

    private let newParamsBindFlag: UInt8

    private let params: Array<Any>

    private init(id: UInt32, flags: CursorType, iterationCount: UInt32, boundFlag: UInt8, params: Array<Any>) {
        super(CommandType.StmtExecute)
        this.statementId = id
        this.flags = flags
        this.iterationCount = iterationCount
        this.parameterCount = UInt64(params.size)
        this.nullBitMap = Array<Byte>((params.size + 7) / 8, repeat: 0)
        this.newParamsBindFlag = boundFlag
        this.params = params
    }

    public static func default(id: UInt32, params: Array<Any>): ExecuteCommand {
        return ExecuteCommand(id, NoCursor, 1, 1, params)
    }

    public static func withReadOnly(id: UInt32, params: Array<Any>): ExecuteCommand {
        return ExecuteCommand(id, ReadOnly, 1, 1, params)
    }

    public override func pack(): Unit {
        super.pack()
        // id
        this.statementId |> buffer.writeInt4
        // flag
        this.flags.value() |> buffer.writeInt1
        // iteration_count
        this.iterationCount |> buffer.writeInt4
        if (parameterCount > 0 || flags == ParameterCountAvailable) {
            if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                //parameter_count
                this.parameterCount |> buffer.writeLengthEncoded
            }
            if (parameterCount > 0) {
                // null_bitmap
                for (i in 0..params.size) {
                    match (params[i]) {
                        case v: ?Any => 
                            if(v.isNone()) {
                                nullBitMap[(i / 8)] |= 1u8 << (i % 8)
                            }
                        case _ => continue
                    }
                }
                this.nullBitMap |> buffer.writeArray

                // new_params_bind_flag
                this.newParamsBindFlag |> buffer.writeInt1
                if (newParamsBindFlag == 1) {
                    //parameter_type
                    for(i in 0..params.size) {
                        match (params[i]) {
                            case v: NativeType => v.writeType(buffer)
                            case v: InputStream => [ColumnType.LongBlob.value(), 0x00] |> buffer.writeArray
                            case v: ?Any => [ColumnType.Null.value(), 0x00] |> buffer.writeArray
                            case _ => throw UnsupportedException("")
                        }
                    }
                    if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                        0x00 |> buffer.writeInt1 //paramter name: default null
                    }
                }

                //parameter_values
                for (i in 0..params.size) {
                    match (params[i]) {
                        case v: NativeType => v.writeValue(buffer)
                        case _: InputStream => continue
                        case _: ?Any => continue
                        case _ => throw UnsupportedException("")
                    }
                }

            }
        }
    }
    
}