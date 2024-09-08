/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.packet

import std.io.*
import std.collection.*
import std.core.StringBuilder

/*
 * Field Count packet
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response.html
 */
protected class ColumnCount <: CommonPacket {

    private var _count: UInt32

    protected prop count: UInt32 {
        get() {
            return _count
        }
    }

    protected ColumnCount(stream: InputStream) {
        super(stream)
        var count = readLengthEncodedInteger(stream)
        if (count.size == 0) {
            throw InvalidPacketException("This packet is not a Column Count packet: read fields count failed")
        }
        _count = littleEndianToUInt32(count)
    }
}

/*
 * Column Definition
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response_text_resultset_column_definition.html
 */
protected class ColumnDefinition <: CommonPacket {
    /*目录名*/
    private var _catalog: String
    /*数据库名*/
    private var _database: String
    /*表名*/
    private var _table: String
    /*原始表名*/
    private var _originalTable: String
    /*字段名*/
    private var _name: String
    /*原始字段名*/
    private var _originalName: String
    /*填充值*/
    private var _padding: Byte
    /*字符串编码*/
    private var _charset: Charset
    /*字段长度*/
    private var _columnLength: UInt32
    /*字段类型*/
    private var _columnType: ColumnType
    /*字段标志*/
    private var _flags: UInt16
    /*浮点型精度*/
    private var _decimals: Byte

    protected ColumnDefinition(stream: InputStream) {
        super(stream)
        var buf: ?Array<Byte>
        buf = readLengthEncodedString(stream)
        this._catalog = String.fromUtf8(
            buf.getOrThrow({=> InvalidPacketException("This packet is not a Field packet: read catalog failed")}))

        buf = readLengthEncodedString(stream)
        this._database = String.fromUtf8(
            buf.getOrThrow({=> InvalidPacketException("This packet is not a Field packet: read database failed")}))

        buf = readLengthEncodedString(stream)
        this._table = String.fromUtf8(
            buf.getOrThrow({=> InvalidPacketException("This packet is not a Field packet: read table failed")}))

        buf = readLengthEncodedString(stream)
        this._originalTable = String.fromUtf8(
            buf.getOrThrow({=> InvalidPacketException("This packet is not a Field packet: read original table failed")})
        )

        buf = readLengthEncodedString(stream)
        this._name = String.fromUtf8(
            buf.getOrThrow({=> InvalidPacketException("This packet is not a Field packet: read name failed")}))

        buf = readLengthEncodedString(stream)
        this._originalName = String.fromUtf8(
            buf.getOrThrow({=> InvalidPacketException("This packet is not a Field packet: read original name failed")}))

        var single = Array<Byte>(1, item: 0)
        if (stream.read(single) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read padding failed")
        }
        this._padding = single[0]
        var charset = Array<Byte>(2, item: 0)
        if (stream.read(charset) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read charset failed")
        }
        _charset = Charset.of(littleEndianToUInt16(charset))
        var fieldLength = Array<Byte>(4, item: 0)
        if (stream.read(fieldLength) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read field length failed")
        }
        this._columnLength = littleEndianToUInt32(fieldLength)
        if (stream.read(single) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read field type failed")
        }
        this._columnType = ColumnType.of(single[0])
        var flags = Array<Byte>(2, item: 0)
        if (stream.read(flags) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read flags failed")
        }
        this._flags = littleEndianToUInt16(flags)
        if (stream.read(single) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read decimals failed")
        }
        this._decimals = single[0]
    }

    protected prop name: String {
        get() {
            _name
        }
    }

    protected prop columnType: ColumnType {
        get() {
            return _columnType
        }
    }

    protected prop fieldLength: UInt32 {
        get() {
            _columnLength
        }
    }

    protected prop charset: Charset {
        get() {
            _charset
        }
    }

    protected prop decimals: Byte {
        get() {
            _decimals
        }
    }

    protected func hasFlag(flag: ColumnFlag): Bool {
        (_flags & flag.value()) != 0
    }
}

/*
 * Text Resultset Row Packet
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response_text_resultset_row.html
 */
protected class TextResult <: CommonPacket {

    private var _values: Array<?Array<Byte>>

    protected prop row: Array<?Array<Byte>> {
        get() {
            _values.toArray()
        }
    }

    protected TextResult(stream: InputStream, columnCount: Int64) {
        super(stream)
        var list = ArrayList<?Array<Byte>>(columnCount)
        var buffer: ?Array<Byte>
        for (_ in 0..columnCount) {
            buffer = readLengthEncodedString(stream)
            if (buffer.isNone()) {
                list.append(None)
            } else {
                list.append(buffer.getOrThrow())
            }
        }
        _values = list.toArray()
    }
}

/*
 * Binary Protocol Resultset
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html
 */
protected class BinaryResult <: Response {
    
    private var _nullMap: Array<Byte>

    private var _binaryData: Array<?Array<Byte>>

    protected prop nullMap: Array<Byte> {
        get() {
            _nullMap
        }
    }

    protected prop binaryData: Array<?Array<Byte>> {
        get() {
            _binaryData
        }
    }

    protected BinaryResult(stream: InputStream, columnInfos: Array<ColumnDefinition>) {
        super(stream)
        var columnCount = columnInfos.size
        var nullMap = Array<Byte>((columnCount + 7 + 2) / 8, item: 0)
        stream.read(nullMap)
        _nullMap = nullMap
        _binaryData = Array<?Array<Byte>>(columnCount, item: [])
        for (i in 0..columnCount) {
            var isNull = (_nullMap[(i + 2) / 8] & (1u8 << ((i + 2) % 8))) != 0
            if (isNull) {
                _binaryData[i] = None
            } else {
                var columnInfo = columnInfos[i]
                var columnType = columnInfo.columnType
                match (columnType) {
                    case Tiny =>
                        var array = Array<Byte>(1, item: 0)
                        stream.read(array)
                        _binaryData[i] = array
                    case Short | Year =>
                        var array = Array<Byte>(2, item: 0)
                        stream.read(array)
                        _binaryData[i] = array
                    case Long | Int24 | Float =>
                        var array = Array<Byte>(4, item: 0)
                        stream.read(array)
                        _binaryData[i] = array
                    case LongLong | Double =>
                        var array = Array<Byte>(8, item: 0)
                        stream.read(array)
                        _binaryData[i] = array
                    case String | NewDecimal | Json | Enum | Set | TinyBlob | MediumBlob | LongBlob | Blob | VarString => _binaryData[i] = readLengthEncodedString(
                        stream)
                    case Date | DateTime | Timestamp | Time =>
                        var single = Array<Byte>(1, item: 0)
                        stream.read(single)
                        var buffer = Array<Byte>(Int64(single[0]), item: 0)
                        stream.read(buffer)
                        var list = ArrayList<Byte>(Int64(1 + single[0]))
                        list.appendAll(single)
                        list.appendAll(buffer)
                        _binaryData[i] = list.toArray()
                    case _ => throw Exception("Unsupport MySQL binary type")
                }
            }
        }
    }
}
