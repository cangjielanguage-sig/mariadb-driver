/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol.request

import std.io.InputStream
import std.time.DateTime
import std.time.TimeParseException
import std.collection.ArrayList
import std.convert.Parsable
import std.math.numeric.Decimal
import std.math.numeric.BigInt
import encoding.json.JsonValue
import mysqlclient4cj.protocol.*
import mysqlclient4cj.protocol.response.*

/*
 * It sends the values for the placeholders of the prepared statement (if it contained any) in Binary Protocol Value form.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_execute.html
 */
protected class ExecuteCommand <: Command {

    private var statementId: UInt32

    private var flags: CursorType

    private var iterationCount: UInt32

    private var parameterCount: UInt64

    private var nullBitMap: Array<Byte>

    private var newParamsBindFlag: UInt8

    private var paramDefinitions: Array<ColumnDefinition>

    private var params: Array<Any>

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
        buf.appendAll(statementId.toLittleEndian())
        // flag
        buf.append(flags.value())
        // iteration_count
        buf.appendAll(iterationCount.toLittleEndian())
        if (parameterCount > 0 || flags == ParameterCountAvailable) {
            if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                //parameter_count
                var array = parameterCount.toLengthEncoded()
                buf.appendAll(array)
            }

            if (parameterCount > 0) {
                // null_bitmap
                for (i in 0..params.size) {
                    var value = params[i]
                    if (value is ?Any && (value as ?Any).getOrThrow().isNone()) {
                        nullBitMap[(i / 8)] |= 1u8 << (i % 8)
                    }
                }
                buf.appendAll(nullBitMap)
                // new_params_bind_flag
                buf.append(newParamsBindFlag)
                if (newParamsBindFlag == 1) {
                    //parameter_type
                    for (i in 0..paramDefinitions.size) {
                        let value = params[i]
                        let paramType = paramDefinitions[i].columnType
                        if (value is ?Any && (value as ?Any).getOrThrow().isNone()) {
                            //buf.append(ColumnType.Null.value())
                            buf.append(0x06)
                        }else {
                            if(paramType == Year){
                                buf.append(ColumnType.Long.value())
                            }else{
                                buf.append(paramType.value())
                            }
                        }
                        if (paramDefinitions[i].hasFlag(Unsigned)) {
                            buf.append(0x80)
                        } else {
                            buf.append(0x00)
                        }
                        if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                            buf.append(0x00) //paramter name: default null
                        }
                    }
                }

                //parameter_values
                for (i in 0..params.size) {
                    var value = params[i]
                    match (value) {
                        case v: Bool => appendBool(i, buf, v)
                        case v: Int8 => appendInt8(i, buf, v)
                        case v: UInt8 => appendUInt8(i, buf, v)
                        case v: Int16 => appendInt16(i, buf, v)
                        case v: UInt16 => appendUInt16(i, buf, v)
                        case v: Int32 => appendInt32(i, buf, v)
                        case v: UInt32 => appendUInt32(i, buf, v)
                        case v: Int64 => appendInt64(i, buf, v)
                        case v: UInt64 => appendUInt64(i, buf, v)
                        case v: Float16 => appendFloat16(i, buf, v)
                        case v: Float32 => appendFloat32(i, buf, v)
                        case v: Float64 => appendFloat64(i, buf, v)
                        case v: BigInt => appendBigInt(i, buf, v)
                        case v: Decimal => appendDecimal(i, buf, v)
                        case v: String => appendString(i, buf, v)
                        case v: DateTime => appendDateTime(i, buf, v)
                        case v: JsonValue => appendJsonValue(i, buf, v)
                        case v: Array<Byte> => nothing(v)
                        case v: InputStream => nothing(v)
                        case v: ?Any => nothing(v) // means null
                        case _ => throw UnsupportedException("Unsupport type")
                    }
                }
            }
        }
    }

    private func appendBool(index: Int64, buf: ArrayList<Byte>, value: Bool): Unit {
        return appendUInt8(index, buf, value.toInteger())
    }

    @OverflowWrapping
    private func appendInt8(index: Int64, buf: ArrayList<Byte>, value: Int8): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value))
            case Short => 
                return appendUInt16(index, buf, UInt16(value))
            case Int24 | Long | Year => 
                return appendUInt32(index, buf, UInt32(value))
            case LongLong => 
                return appendUInt64(index, buf, UInt64(value))
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter as position ${index + 1} is Int8 type, don't match the required type ${paramType}")
            }
    }

    private func appendUInt8(index: Int64, buf: ArrayList<Byte>, value: UInt8): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                buf.append(value)
            case Short => 
                return appendUInt16(index, buf, UInt16(value))
            case Long | Int24 | Year => 
                return appendUInt32(index, buf, UInt32(value))
            case LongLong => 
                return appendUInt64(index, buf, UInt64(value))
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter as position ${index + 1} is Int8 type, don't match the required type ${paramType}")
            }
    }

    @OverflowWrapping
    private func appendInt16(index: Int64, buf: ArrayList<Byte>, value: Int16): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value))
            case Short => 
                return appendUInt16(index, buf, UInt16(value))
            case Int24 | Long | Year => 
                return appendUInt32(index, buf, UInt32(value))
            case LongLong => 
                return appendUInt64(index, buf, UInt64(value))
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter as position ${index + 1} is Int8 type, don't match the required type ${paramType}")
            }
    }

    private func appendUInt16(index: Int64, buf: ArrayList<Byte>, value: UInt16): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value)) // possible overflow
            case Short => 
                buf.appendAll(value.toLittleEndian())
            case Long | Int24 | Year => 
                return appendUInt32(index, buf, UInt32(value))
            case LongLong => 
                return appendUInt64(index, buf, UInt64(value))
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
            }
    }

    @OverflowWrapping
    private func appendInt32(index: Int64, buf: ArrayList<Byte>, value: Int32): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value))
            case Short => 
                return appendUInt16(index, buf, UInt16(value))
            case Int24 | Long | Year => 
                return appendUInt32(index, buf, UInt32(value))
            case LongLong => 
                return appendUInt64(index, buf, UInt64(value))
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")      
            }
    }

    private func appendUInt32(index: Int64, buf: ArrayList<Byte>, value: UInt32): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value)) // possible overflow
            case Short =>
                return appendUInt16(index, buf, UInt16(value)) // possible overflow
            case Int24 | Long | Year => 
                buf.appendAll(value.toLittleEndian())
            case LongLong => 
                return appendUInt64(index, buf, UInt64(value))
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
            }
    }

    @OverflowWrapping
    private func appendInt64(index: Int64, buf: ArrayList<Byte>, value: Int64): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value))
            case Short => 
                return appendUInt16(index, buf, UInt16(value))
            case Int24 | Long | Year => 
                return appendUInt32(index, buf, UInt32(value))
            case LongLong => 
                return appendUInt64(index, buf, UInt64(value))
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
            }
    }

    private func appendUInt64(index: Int64, buf: ArrayList<Byte>, value: UInt64): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value)) // possible overflow
            case Short => 
                return appendUInt16(index, buf, UInt16(value)) // possible overflow
            case Int24 | Long | Year => 
                return appendUInt32(index, buf, UInt32(value)) // possible overflow
            case LongLong => 
                buf.appendAll(value.toLittleEndian())
            case Float => 
                return appendFloat32(index, buf, Float32(value))
            case Double => 
                return appendFloat64(index, buf, Float64(value))
            case String | VarString | NewDecimal => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
            }
    }

    private func appendFloat16(index: Int64, buf: ArrayList<Byte>, value: Float16): Unit {
        return appendFloat64(index, buf, Float64(value))
    }

    private func appendFloat32(index: Int64, buf: ArrayList<Byte>, value: Float32): Unit {
        return appendFloat64(index, buf, Float64(value))
    }

    private func appendFloat64(index: Int64, buf: ArrayList<Byte>, value: Float64): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Float =>
                return appendFloat32(index, buf, Float32(value)) //possible loss of precision
            case Double => 
                buf.appendAll(value.toLittleEndian())
            case Tiny => 
                return appendInt8(index, buf, Int8(value))
            case Short =>
                return appendInt16(index, buf, Int16(value))
            case Int24 | Long  => 
                return appendInt32(index, buf, Int32(value))
            case LongLong => 
                return appendInt64(index, buf, Int64(value))
            case String | VarString | NewDecimal  => 
                return appendString(index, buf, value.toString())
            case _ => 
                throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
            }
    }

    private func appendBigInt(index: Int64, buf: ArrayList<Byte>, value: BigInt): Unit {
        return appendString(index, buf, value.toString())
    }

    private func appendDecimal(index: Int64, buf: ArrayList<Byte>, value: Decimal): Unit {
        return appendString(index, buf, value.toString())
    }

    private func appendString(index: Int64, buf: ArrayList<Byte>, value: String): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case String | VarString | NewDecimal | Json | TinyBlob | Blob | MediumBlob | LongBlob =>
                buf.appendAll(value.toLengthEncoded())
            case Tiny | Short | Year | Int24 | Long | LongLong => 
                try {
                    return appendInt64(index, buf, Int64.parse(value))
                }catch (e: IllegalArgumentException) {
                    throw ParameterConvertException("parameter convert to integer failed: index : ${index + 1}, raw value: ${value}")
                }
            case Float | Double => 
                try {
                    return appendFloat64(index, buf, Float64.parse(value))
                }catch (e: IllegalArgumentException) {
                    throw ParameterConvertException("parameter convert to float/double failed: index : ${index + 1}, raw value: ${value}")
                }
            case Date => 
                try {
                    return appendDateTime(index, buf, DateTime.parse(value, DB_DATE_FORMAT))
                }catch(e: TimeParseException) {
                    throw ParameterConvertException("parameter convert to date failed: index : ${index + 1}, raw value: ${value}")
                }
            case Time =>
                try {
                    return appendDateTime(index, buf, DateTime.parse(DB_TIME_PREFIX + value, DB_DATE_TIME_FORMAT))
                }catch (e: TimeParseException) {
                    throw ParameterConvertException("parameter convert to time failed: index : ${index + 1}, raw value: ${value}")
                }
            case DateTime | Timestamp =>
                try {
                    return appendDateTime(index, buf, DateTime.parse(value, DB_DATE_TIME_FORMAT))
                }catch (e: TimeParseException) {
                    throw ParameterConvertException("parameter convert to datetime/timestamp failed: index : ${index + 1}, raw value: ${value}")
                }
            case _ => 
                throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
            }
    }

    private func appendDateTime(index: Int64, buf: ArrayList<Byte>, value: DateTime): Unit {
        let paramType = paramDefinitions[index].columnType
        match (paramType) {
            case Timestamp | DateTime => 
                buf.appendAll(value.toBinaryDateTime())
            case Date => 
                buf.appendAll(value.toBinaryDate())
            case Time =>
                buf.appendAll(value.toBinaryTime())
            case Year =>
                appendInt32(index, buf, Int32(value.year))
            case _ => throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
        }
    }

    private func appendJsonValue(index: Int64, buf: ArrayList<Byte>, value: JsonValue): Unit {
        return appendString(index, buf, value.toJsonString())
    }
}