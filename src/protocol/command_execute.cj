/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.io.InputStream
import std.time.DateTime
import std.time.TimeParseException
import std.collection.ArrayList
import std.convert.Parsable
import std.math.numeric.Decimal
import std.math.numeric.BigInt
import encoding.json.JsonValue

/*
 * It sends the values for the placeholders of the prepared statement (if it contained any) in Binary Protocol Value form.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_execute.html
 */
protected class ExecuteCommand <: Command {

    private var _statementId: UInt32

    private var _flags: CursorType

    private var _iterationCount: UInt32

    private var _parameterCount: UInt64

    private var _nullBitMap: Array<Byte>

    private var _newParamsBindFlag: UInt8

    private var _paramDefinition: Array<ColumnDefinition>

    private var _params: Array<Any>

    private init(
        id: UInt32,
        flags: CursorType,
        iterationCount: UInt32,
        parameterCount: UInt64,
        boundFlag: UInt8,
        parameterDefinition: Array<ColumnDefinition>,
        params: Array<Any>
    ) {
        super(CommandType.StmtExecute)
        if (parameterDefinition.size != params.size) {
            throw IllegalArgumentException("values size must equals parameter size")
        }
        _statementId = id
        _flags = flags
        _iterationCount = iterationCount
        _parameterCount = parameterCount
        _nullBitMap = Array<Byte>((Int64(_parameterCount) + 7) / 8, repeat: 0)
        _newParamsBindFlag = boundFlag
        _paramDefinition = parameterDefinition
        _params = params
    }

    public static func default(id: UInt32, paramDefinition: Array<ColumnDefinition>, params: Array<Any>): ExecuteCommand {
        return ExecuteCommand(id, ParameterCountAvailable, 1, UInt64(paramDefinition.size), 1, paramDefinition, params)
    }

    public static func withReadOnly(id: UInt32, paramDefinition: Array<ColumnDefinition>, params: Array<Any>): ExecuteCommand {
        return ExecuteCommand(id, ReadOnly , 1, UInt64(paramDefinition.size), 1, paramDefinition, params)
    }

    public override func pack(): Unit {
        super.pack()
        var len = 0
        // id
        buf.appendAll(_statementId.toLittleEndian())
        len += 4
        // flag
        buf.append(_flags.value())
        len += 1
        // iteration_count
        buf.appendAll(_iterationCount.toLittleEndian())
        len += 4
        if (_parameterCount > 0 || _flags == ParameterCountAvailable) {
            if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                //parameter_count
                var array = toLengthEncoded(_parameterCount)
                buf.appendAll(array)
                len += array.size
            }

            if (_parameterCount > 0) {
                // null_bitmap
                for (i in 0.._params.size) {
                    var value = _params[i]
                    if (value is ?Any && (value as ?Any).getOrThrow().isNone()) {
                        _nullBitMap[(i / 8)] |= 1u8 << (i % 8)
                    }
                }
                buf.appendAll(_nullBitMap)
                len += _nullBitMap.size
                // new_params_bind_flag
                buf.append(_newParamsBindFlag)
                len += 1
                if (_newParamsBindFlag == 1) {
                    //parameter_type
                    for (i in 0.._paramDefinition.size) {
                        let value = _params[i]
                        let paramType = _paramDefinition[i].columnType
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
                        if (_paramDefinition[i].hasFlag(Unsigned)) {
                            buf.append(0x80)
                        } else {
                            buf.append(0x00)
                        }
                        len += 2
                        if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                            buf.append(0x00) //paramter name: default null
                            len += 1
                        }
                    }
                }

                //parameter_values
                for (i in 0.._params.size) {
                    var value = _params[i]
                    match (value) {
                        case v: Bool => len += appendBool(i, buf, v)
                        case v: Int8 => len += appendInt8(i, buf, v)
                        case v: UInt8 => len += appendUInt8(i, buf, v)
                        case v: Int16 => len += appendInt16(i, buf, v)
                        case v: UInt16 => len += appendUInt16(i, buf, v)
                        case v: Int32 => len += appendInt32(i, buf, v)
                        case v: UInt32 => len += appendUInt32(i, buf, v)
                        case v: Int64 => len += appendInt64(i, buf, v)
                        case v: UInt64 => len += appendUInt64(i, buf, v)
                        case v: Float16 => len += appendFloat16(i, buf, v)
                        case v: Float32 => len += appendFloat32(i, buf, v)
                        case v: Float64 => len += appendFloat64(i, buf, v)
                        case v: BigInt => len += appendBigInt(i, buf, v)
                        case v: Decimal => len += appendDecimal(i, buf, v)
                        case v: String => len += appendString(i, buf, v)
                        case v: DateTime => len += appendDateTime(i, buf, v)
                        case v: JsonValue => len += appendJsonValue(i, buf, v)
                        case v: Array<Byte> => nothingTodo(v)
                        case v: InputStream => nothingTodo(v)
                        case v: ?Any => nothingTodo(v) // means null
                        case _ => throw UnsupportedException("Unsupport type")
                    }
                }
            }
        }
        var subLen = _length + UInt32(len)
        reset(subLen)
    }

    private func appendBool(index: Int64, buf: ArrayList<Byte>, value: Bool): Int64 {
        return appendUInt8(index, buf, toInteger(value))
    }

    @OverflowWrapping
    private func appendInt8(index: Int64, buf: ArrayList<Byte>, value: Int8): Int64 {
        let paramType = _paramDefinition[index].columnType
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

    private func appendUInt8(index: Int64, buf: ArrayList<Byte>, value: UInt8): Int64 {
        let paramType = _paramDefinition[index].columnType
        match (paramType) {
            case Tiny => 
                buf.append(value)
                return 1
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
    private func appendInt16(index: Int64, buf: ArrayList<Byte>, value: Int16): Int64 {
        let paramType = _paramDefinition[index].columnType
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

    private func appendUInt16(index: Int64, buf: ArrayList<Byte>, value: UInt16): Int64 {
        let paramType = _paramDefinition[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value)) // possible overflow
            case Short => 
                buf.appendAll(value.toLittleEndian())
                return 2
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
    private func appendInt32(index: Int64, buf: ArrayList<Byte>, value: Int32): Int64 {
        let paramType = _paramDefinition[index].columnType
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

    private func appendUInt32(index: Int64, buf: ArrayList<Byte>, value: UInt32): Int64 {
        let paramType = _paramDefinition[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value)) // possible overflow
            case Short =>
                return appendUInt16(index, buf, UInt16(value)) // possible overflow
            case Int24 | Long | Year => 
                buf.appendAll(value.toLittleEndian())
                return 4
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
    private func appendInt64(index: Int64, buf: ArrayList<Byte>, value: Int64): Int64 {
        let paramType = _paramDefinition[index].columnType
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

    private func appendUInt64(index: Int64, buf: ArrayList<Byte>, value: UInt64): Int64 {
        let paramType = _paramDefinition[index].columnType
        match (paramType) {
            case Tiny => 
                return appendUInt8(index, buf, UInt8(value)) // possible overflow
            case Short => 
                return appendUInt16(index, buf, UInt16(value)) // possible overflow
            case Int24 | Long | Year => 
                return appendUInt32(index, buf, UInt32(value)) // possible overflow
            case LongLong => 
                buf.appendAll(value.toLittleEndian())
                return 8
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

    private func appendFloat16(index: Int64, buf: ArrayList<Byte>, value: Float16): Int64 {
        return appendFloat64(index, buf, Float64(value))
    }

    private func appendFloat32(index: Int64, buf: ArrayList<Byte>, value: Float32): Int64 {
        return appendFloat64(index, buf, Float64(value))
    }

    private func appendFloat64(index: Int64, buf: ArrayList<Byte>, value: Float64): Int64 {
        let paramType = _paramDefinition[index].columnType
        match (paramType) {
            case Float =>
                return appendFloat32(index, buf, Float32(value)) //possible loss of precision
            case Double => 
                buf.appendAll(value.toLittleEndian())
                return 8
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

    private func appendBigInt(index: Int64, buf: ArrayList<Byte>, value: BigInt): Int64 {
        return appendString(index, buf, value.toString())
    }

    private func appendDecimal(index: Int64, buf: ArrayList<Byte>, value: Decimal): Int64 {
        return appendString(index, buf, value.toString())
    }

    private func appendString(index: Int64, buf: ArrayList<Byte>, value: String): Int64 {
        let paramType = _paramDefinition[index].columnType
        match (paramType) {
            case String | VarString | NewDecimal | Json | TinyBlob | Blob | MediumBlob | LongBlob =>
                let array = toLengthEncoded(value)
                buf.appendAll(array)
                return array.size
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

    private func appendDateTime(index: Int64, buf: ArrayList<Byte>, value: DateTime): Int64 {
        let paramType = _paramDefinition[index].columnType
        match (paramType) {
            case Timestamp | DateTime => 
                let array = toBinaryDateTime(value)
                buf.appendAll(array)
                return array.size
            case Date => 
                let array = toBinaryDate(value)
                buf.appendAll(array)
                return array.size
            case Time =>
                let array = toBinaryTime(value)
                buf.appendAll(array)
                return array.size
            case Year =>
                appendInt32(index, buf, Int32(value.year))
                return 2
            case _ => throw IllegalArgumentException("The parameter type at position ${index + 1} does not match the required type: ${paramType}")
            }
    }

    private func appendJsonValue(index: Int64, buf: ArrayList<Byte>, value: JsonValue): Int64 {
        return appendString(index, buf, value.toJsonString())
    }
}