/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.protocol

import std.collection.*
import std.time.*
import encoding.json.*
import std.convert.*
import encoding.hex.*
import std.io.*
import std.math.numeric.*

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

    private var _values: Array<Any>

    private init(
        id: UInt32,
        flags: CursorType,
        iterationCount: UInt32,
        parameterCount: UInt64,
        boundFlag: UInt8,
        parameterDefinition: Array<ColumnDefinition>,
        values: Array<Any>
    ) {
        super(CommandType.StmtExecute)
        if (parameterDefinition.size != values.size) {
            println(parameterDefinition.size)
            println(values.size)
            throw Exception("values size must equals parameter size")
        }
        _statementId = id
        _flags = flags
        _iterationCount = iterationCount
        _parameterCount = parameterCount
        _nullBitMap = Array<Byte>((Int64(_parameterCount) + 7) / 8, repeat: 0)
        _newParamsBindFlag = boundFlag
        _paramDefinition = parameterDefinition
        _values = values
    }

    public static func default(id: UInt32, paramDefinition: Array<ColumnDefinition>, values: Array<Any>): ExecuteCommand {
        return ExecuteCommand(id, ParameterCountAvailable, 1, UInt64(paramDefinition.size), 1, paramDefinition,values)
    }

    public override func toByteArray(): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(super.toByteArray())
        var length = 0
        // id
        list.appendAll(uInt32ToLittleEndian(_statementId))
        length += 4
        // flag
        list.append(_flags.value())
        length += 1
        // iteration_count
        list.appendAll(uInt32ToLittleEndian(_iterationCount))
        length += 4
        if (_parameterCount > 0 || _flags == ParameterCountAvailable) {
            if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                //parameter_count
                var array = integerToLengthEncoded(_parameterCount)
                list.appendAll(array)
                length += array.size
            }

            if (_parameterCount > 0) {
                // null_bitmap
                for (i in 0.._values.size) {
                    var value = _values[i]
                    if (value is ?Any && (value as ?Any).getOrThrow().isNone()) {
                        _nullBitMap[(i / 8)] |= 1u8 << (i % 8)
                    }
                }
                //_nullBitMap.reverse()
                list.appendAll(_nullBitMap)
                length += _nullBitMap.size
                // new_params_bind_flag
                list.append(_newParamsBindFlag)
                length += 1
                if (_newParamsBindFlag == 1) {
                    //parameter_type
                    for (i in 0.._paramDefinition.size) {
                        var value = _values[i]
                        var columnType = _paramDefinition[i].columnType
                        if (value is ?Any && (value as ?Any).getOrThrow().isNone()) {
                            list.append(ColumnType.Null.value())
                        }else {
                            if(columnType == Year){
                                list.append(ColumnType.Long.value())
                            }else{
                                list.append(columnType.value())
                            }
                        }
                        if (_paramDefinition[i].hasFlag(Unsigned)) {
                            list.append(0x80)
                        } else {
                            list.append(0x00)
                        }
                        length += 2
                        if (HandshakeResponse.getDefault(0).hasCapability(QueryAttributes)) {
                            list.append(0x00) //paramter name: default null
                            length += 1
                        }
                    }
                }

                //parameter_values
                for (i in 0.._values.size) {
                    var value = _values[i]
                    match (value) {
                        case v: Bool => length += appendBool(i, list, v)
                        case v: Int8 => length += appendInt8(i, list, v)
                        case v: UInt8 => length += appendUInt8(i, list, v)
                        case v: Int16 => length += appendInt16(i, list, v)
                        case v: UInt16 => length += appendUInt16(i, list, v)
                        case v: Int32 => length += appendInt32(i, list, v)
                        case v: UInt32 => length += appendUInt32(i, list, v)
                        case v: Int64 => length += appendInt64(i, list, v)
                        case v: UInt64 => length += appendUInt64(i, list, v)
                        case v: Float16 => length += appendFloat16(i, list, v)
                        case v: Float32 => length += appendFloat32(i, list, v)
                        case v: Float64 => length += appendFloat64(i, list, v)
                        case v: BigInt => length += appendBigInt(i, list, v)
                        case v: Decimal => length += appendDecimal(i, list, v)
                        case v: String => length += appendString(i, list, v)
                        case v: DateTime => length += appendDateTime(i, list, v)
                        case v: JsonValue => length += appendJsonValue(i, list, v)
                        case v: Array<Byte> => nothingTodo(v)
                        case v: InputStream => nothingTodo(v)
                        case v: ?Bool => length += appendBool(i, list, v)
                        case v: ?Int8 => length += appendInt8(i, list, v)
                        case v: ?UInt8 => length += appendUInt8(i, list, v)
                        case v: ?Int16 => length += appendInt16(i, list, v)
                        case v: ?UInt16 => length += appendUInt16(i, list, v)
                        case v: ?Int32 => length += appendInt32(i, list, v)
                        case v: ?UInt32 => length += appendUInt32(i, list, v)
                        case v: ?Int64 => length += appendInt64(i, list, v)
                        case v: ?UInt64 => length += appendUInt64(i, list, v)
                        case v: ?Float16 => length += appendFloat16(i, list, v)
                        case v: ?Float32 => length += appendFloat32(i, list, v)
                        case v: ?Float64 => length += appendFloat64(i, list, v)
                        case v: ?Decimal => length += appendDecimal(i, list, v)
                        case v: ?String => length += appendString(i, list, v)
                        case v: ?DateTime => length += appendDateTime(i, list, v)
                        case v: ?JsonValue => length += appendJsonValue(i, list, v)
                        case v: ?Array<Byte> => nothingTodo(v)
                        case v: ?InputStream => nothingTodo(v)
                        case v: ?Any => nothingTodo(v)
                        case _ => throw UnsupportedException("Unsupport type")
                    }
                }
            }
        }
        var packetLen = _length + UInt32(length)
        var array = uInt32ToLittleEndian(packetLen)
        list[0] = array[0]
        list[1] = array[1]
        list[2] = array[2]
        return list.toArray()
    }

    private func appendBool(index: Int64, list: ArrayList<Byte>, value: ?Bool): Int64 {
        if (!value.isNone()) {
            var bool = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(boolToInteger(bool)))
                case Short => 
                    return appendUInt16(index, list, UInt16(boolToInteger(bool)))
                case Long => 
                    return appendUInt32(index, list, UInt32(boolToInteger(bool)))
                case LongLong => 
                    return appendUInt64(index, list, UInt64(boolToInteger(bool)))
                case String | VarString => 
                    return appendString(index, list, boolToInteger(bool).toString())
                case _ => 
                    throw Exception("The parameter of the Bool type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    @OverflowWrapping
    private func appendInt8(index: Int64, list: ArrayList<Byte>, value: ?Int8): Int64 {
        if (!value.isNone()) {
            var columnType = _paramDefinition[index].columnType
            var integer = value.getOrThrow()
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(integer))
                case Short => 
                    return appendUInt16(index, list, UInt16(integer))
                case Int24 | Long | Year => 
                    return appendUInt32(index, list, UInt32(integer))
                case LongLong => 
                    return appendUInt64(index, list, UInt64(integer))
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => 
                    throw Exception("The parameter of the Int8 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendUInt8(index: Int64, list: ArrayList<Byte>, value: ?UInt8): Int64 {
        if (!value.isNone()) {
            var integer = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Tiny => 
                    list.append(integer)
                    return 1
                case Short => 
                    return appendUInt16(index, list, UInt16(integer))
                case Long | Int24 | Year => 
                    return appendUInt32(index, list, UInt32(integer))
                case LongLong => 
                    return appendUInt64(index, list, UInt64(integer))
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => 
                    throw Exception("The parameter of the UInt8 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    @OverflowWrapping
    private func appendInt16(index: Int64, list: ArrayList<Byte>, value: ?Int16): Int64 {
        if (!value.isNone()) {
            var columnType = _paramDefinition[index].columnType
            var integer = value.getOrThrow()
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(integer))
                case Short => 
                    return appendUInt16(index, list, UInt16(integer))
                case Int24 | Long | Year => 
                    return appendUInt32(index, list, UInt32(integer))
                case LongLong => 
                    return appendUInt64(index, list, UInt64(integer))
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => throw Exception("The parameter of the Int16 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendUInt16(index: Int64, list: ArrayList<Byte>, value: ?UInt16): Int64 {
        if (!value.isNone()) {
            var integer: UInt16 = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(integer)) // possible overflow
                case Short => 
                    list.appendAll(uInt16ToLittleEndian(integer))
                    return 2
                case Long | Int24 | Year => 
                    return appendUInt32(index, list, UInt32(integer))
                case LongLong => 
                    return appendUInt64(index, list, UInt64(integer))
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => 
                    throw Exception("The parameter of the UInt16 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    @OverflowWrapping
    private func appendInt32(index: Int64, list: ArrayList<Byte>, value: ?Int32): Int64 {
        if (!value.isNone()) {
            var columnType = _paramDefinition[index].columnType
            var integer = value.getOrThrow()
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(integer))
                case Short => 
                    return appendUInt16(index, list, UInt16(integer))
                case Int24 | Long | Year => 
                    return appendUInt32(index, list, UInt32(integer))
                case LongLong => 
                    return appendUInt64(index, list, UInt64(integer))
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => 
                    throw Exception("The parameter of the Int32 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendUInt32(index: Int64, list: ArrayList<Byte>, value: ?UInt32): Int64 {
        if (!value.isNone()) {
            var integer: UInt32 = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(integer)) // possible overflow
                case Short =>
                    return appendUInt16(index, list, UInt16(integer)) // possible overflow
                case Int24 | Long | Year => 
                    list.appendAll(uInt32ToLittleEndian(integer))
                    return 4
                case LongLong => 
                    return appendUInt64(index, list, UInt64(integer))
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => 
                    throw Exception("The parameter of the UInt32 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    @OverflowWrapping
    private func appendInt64(index: Int64, list: ArrayList<Byte>, value: ?Int64): Int64 {
        if (!value.isNone()) {
            var columnType = _paramDefinition[index].columnType
            var integer = value.getOrThrow()
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(integer))
                case Short => 
                    return appendUInt16(index, list, UInt16(integer))
                case Int24 | Long | Year => 
                    return appendUInt32(index, list, UInt32(integer))
                case LongLong => 
                    return appendUInt64(index, list, UInt64(integer))
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => 
                    throw Exception("The parameter of the Int64 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendUInt64(index: Int64, list: ArrayList<Byte>, value: ?UInt64): Int64 {
        if (!value.isNone()) {
            var integer = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Tiny => 
                    return appendUInt8(index, list, UInt8(integer)) // possible overflow
                case Short => 
                    return appendUInt16(index, list, UInt16(integer)) // possible overflow
                case Int24 | Long | Year => 
                    return appendUInt32(index, list, UInt32(integer)) // possible overflow
                case LongLong => 
                    list.appendAll(uInt64ToLittleEndian(integer))
                    return 8
                case Float => 
                    return appendFloat32(index, list, Float32(integer))
                case Double => 
                    return appendFloat64(index, list, Float64(integer))
                case String | VarString | NewDecimal => 
                    return appendString(index, list, integer.toString())
                case _ => 
                    throw Exception("The parameter of the UInt64 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendFloat16(index: Int64, list: ArrayList<Byte>, value: ?Float16): Int64 {
        if (!value.isNone()) {
            var float = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Float => return appendFloat32(index, list, Float32(float))
                case Double => return appendFloat64(index, list, Float64(float))
                case Short =>
                    return appendInt16(index, list, Int16(float))
                case Int24 | Long  => 
                    return appendInt32(index, list, Int32(float))
                case LongLong => 
                    return appendInt64(index, list, Int64(float))
                case String | VarString | NewDecimal  => 
                    return appendString(index, list, float.toString())
                case _ => 
                    throw ParameterConvertException("The parameter of the Float32 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendFloat32(index: Int64, list: ArrayList<Byte>, value: ?Float32): Int64 {
        if (!value.isNone()) {
            var float = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Float =>
                     list.appendAll(float32ToLittleEndian(float))
                     return 4
                case Double => 
                    return appendFloat64(index, list, Float64(float))
                case Short =>
                    return appendInt16(index, list, Int16(float))
                case Int24 | Long  => 
                    return appendInt32(index, list, Int32(float))
                case LongLong => 
                    return appendInt64(index, list, Int64(float))
                case String | VarString | NewDecimal  => 
                    return appendString(index, list, float.toString())
                case _ => 
                    throw ParameterConvertException("The parameter of the Float32 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendFloat64(index: Int64, list: ArrayList<Byte>, value: ?Float64): Int64 {
        if (!value.isNone()) {
            var float = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Float =>
                    return appendFloat32(index, list, Float32(float)) //possible loss of precision
                case Double => 
                    list.appendAll(float64ToLittleEndian(float))
                    return 8
                case Tiny => 
                    return appendInt8(index, list, Int8(float))
                case Short =>
                    return appendInt16(index, list, Int16(float))
                case Int24 | Long  => 
                    return appendInt32(index, list, Int32(float))
                case LongLong => 
                    return appendInt64(index, list, Int64(float))
                case String | VarString | NewDecimal  => 
                    return appendString(index, list, float.toString())
                case _ => 
                    throw ParameterConvertException("The parameter of the Float64 type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendBigInt(index: Int64, list: ArrayList<Byte>, value: ?BigInt): Int64 {
        match (value) {
            case None => 0
            case Some(s) => appendString(index, list, s.toString(10))
        }
    }

    private func appendDecimal(index: Int64, list: ArrayList<Byte>, value: ?Decimal): Int64 {
        match (value) {
            case None => 0
            case Some(s) => appendString(index, list, s.toString())
        }
    }

    private func appendString(index: Int64, list: ArrayList<Byte>, value: ?String): Int64 {
        if (!value.isNone()) {
            var str = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case String | VarString | NewDecimal | Json | TinyBlob | Blob | MediumBlob | LongBlob =>
                    var array = stringToLengthEncoded(str)
                    list.appendAll(stringToLengthEncoded(str))
                    return array.size
                case Tiny | Short | Year | Int24 | Long | LongLong => 
                    try {
                        return appendInt64(index, list, Int64.parse(str))
                    }catch (e: IllegalArgumentException) {
                        throw ParameterConvertException("parameter convert to integer failed: index : ${index + 1}, raw value: ${str}")
                    }
                case Float | Double => 
                    try {
                        return appendFloat64(index, list, Float64.parse(str))
                    }catch (e: IllegalArgumentException) {
                        throw ParameterConvertException("parameter convert to float/double failed: index : ${index + 1}, raw value: ${str}")
                    }
                case Date => 
                    try {
                        return appendDateTime(index, list, DateTime.parse(str, DB_DATE_FORMAT))
                    }catch(e: TimeParseException) {
                        throw ParameterConvertException("parameter convert to date failed: index : ${index + 1}, raw value: ${str}")
                    }
                case Time =>
                    try {
                        return appendDateTime(index, list, DateTime.parse(DB_TIME_PREFIX + str, DB_DATE_TIME_FORMAT))
                    }catch (e: TimeParseException) {
                        throw ParameterConvertException("parameter convert to time failed: index : ${index + 1}, raw value: ${str}")
                    }
                case DateTime | Timestamp =>
                    try {
                        return appendDateTime(index, list, DateTime.parse(str,DB_DATE_TIME_FORMAT))
                    }catch (e: TimeParseException) {
                        throw ParameterConvertException("parameter convert to datetime/timestamp failed: index : ${index + 1}, raw value: ${str}")
                    }
                case _ => 
                    throw Exception("The parameter of the String type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendDateTime(index: Int64, list: ArrayList<Byte>, value: ?DateTime): Int64 {
        if (!value.isNone()) {
            var dateTime = value.getOrThrow()
            var columnType = _paramDefinition[index].columnType
            match (columnType) {
                case Timestamp | DateTime => 
                    var array = dateTimeToProtocolBinaryDateTime(dateTime)
                    list.appendAll(array)
                    return array.size
                case Date => 
                    var array = dateTimeToProtocolBinaryDate(dateTime)
                    list.appendAll(array)
                    return array.size
                case Time =>
                    var array = dateTimeToProtocolBinaryTime(dateTime)
                    list.appendAll(array)
                    return array.size
                case Year =>
                    appendInt32(index, list, Int32(dateTime.year))
                    return 2
                case _ => throw Exception("The parameter of the DateTime type does not match the corresponding column type ${columnType}")
            }
        }
        return 0
    }

    private func appendJsonValue(index: Int64, list: ArrayList<Byte>, value: ?JsonValue): Int64 {
        if(!value.isNone()) {
            return appendString(index, list, value.getOrThrow().toJsonString())
        }
        return 0
    }
}