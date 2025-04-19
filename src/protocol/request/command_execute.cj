/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.request

import std.io.*
import std.time.*
import std.convert.*
import std.collection.*
import std.math.numeric.*
import encoding.json.*
import mysql.util.*
import mysql.protocol.*
import mysql.protocol.response.*

/*
 * It sends the values for the placeholders of the prepared statement (if it contained any) in Binary Protocol Value form.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_execute.html
 */
protected class ExecuteCommand <: Command {

    private let statementId: UInt32

    private let flags: CursorType

    private let iterationCount: UInt32

    private let parameterCount: UInt64

    private let nullBitMap: Array<Byte>

    private let newParamsBindFlag: UInt8

    private let paramDefinitions: Array<ColumnDefinition>

    private let params: Array<Any>

    private init(id: UInt32, flags: CursorType, iterationCount: UInt32, parameterCount: UInt64, boundFlag: UInt8, 
                parameterDefinition: Array<ColumnDefinition>, params: Array<Any>) {
        super(CommandType.StmtExecute)
        if (parameterDefinition.size != params.size) {
            throw IllegalArgumentException("values size must equals parameter size")
        }
        this.statementId = id
        this.flags = flags
        this.iterationCount = iterationCount
        this.parameterCount = parameterCount
        this.nullBitMap = Array<Byte>((Int64(parameterCount) + 7) / 8, repeat: 0)
        this.newParamsBindFlag = boundFlag
        this.paramDefinitions = parameterDefinition
        this.params = params
    }

    public static func default(id: UInt32, paramDefinitions: Array<ColumnDefinition>, params: Array<Any>): ExecuteCommand {
        return ExecuteCommand(id, ParameterCountAvailable, 1, UInt64(paramDefinitions.size), 1, paramDefinitions, params)
    }

    public static func withReadOnly(id: UInt32, paramDefinitions: Array<ColumnDefinition>, params: Array<Any>): ExecuteCommand {
        return ExecuteCommand(id, ReadOnly , 1, UInt64(paramDefinitions.size), 1, paramDefinitions, params)
    }

    public override func pack(): Unit {
        super.pack()
        // id
        this.statementId.toLittleEndian() |> pack
        // flag
        this.flags.value() |> pack
        // iteration_count
        this.iterationCount.toLittleEndian() |> pack
        if (parameterCount > 0 || flags == ParameterCountAvailable) {
            if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                //parameter_count
                this.parameterCount.toLengthEncoded() |> pack
            }
            if (parameterCount > 0) {
                // null_bitmap
                for (i in 0..params.size) {
                    let value = params[i]
                    if (value is ?Any && (value as ?Any).getOrThrow().isNone()) {
                        nullBitMap[(i / 8)] |= 1u8 << (i % 8)
                    }
                }
                this.nullBitMap |> pack
                // new_params_bind_flag
                this.newParamsBindFlag |> pack
                if (newParamsBindFlag == 1) {
                    //parameter_type
                    for (i in 0..paramDefinitions.size) {
                        let value = params[i]
                        let paramType = paramDefinitions[i].columnType
                        if (value is ?Any && (value as ?Any).getOrThrow().isNone()) {
                            //buf.append(ColumnType.Null.value())
                            0x06 |> pack
                        }else {
                            if(paramType == Year){
                               ColumnType.Long.value() |> pack
                            }else{
                                paramType.value() |> pack
                            }
                        }
                        if (paramDefinitions[i].hasFlag(Unsigned)) {
                            0x80 |> pack
                        } else {
                            0x00 |> pack
                        }
                        if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                            0x00 |> pack//paramter name: default null
                        }
                    }
                }
                //parameter_values
                for (i in 0..params.size) {
                    let value = params[i]
                    match (value) {
                        case v: ToMySqlBinary => v.toBinary(paramDefinitions[i]) |> pack
                        case _: Array<Byte> => continue
                        case _: InputStream => continue
                        case _: ?Any => continue
                        case _ => throw UnsupportedException("Unsupport type")
                    }
                }
            }
        }
    }
    
}