/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol.response

import std.io.ByteBuffer
import std.collection.ArrayList
import mysqlclient4cj.protocol.*
/*
 * Field Count packet
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response.html
 */
protected class ColumnCount <: CommonResponse {

    private var _count: UInt32

    protected prop count: UInt32 {
        get() {
            return _count
        }
    }

    protected init(length: UInt32, buffer: ByteBuffer) {
        super(length, buffer) 
        match (buffer.readLengthEncodedIntegerRaw()) {
            case None => throw InvalidPacketException("This packet is not a Column Count packet: read fields count failed")
            case Some(v) => _count = UInt32.fromLittleEndian(v)
        }
    }
}

/*
 * Column Definition
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response_text_resultset_column_definition.html
 */
protected class ColumnDefinition <: CommonResponse {
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

    protected init(length: UInt32, buffer: ByteBuffer) {
        super(length, buffer)
        _catalog = buffer.readLengthEncodedString().getOrThrow() {
            => InvalidPacketException("This packet is not a Field packet: read catalog failed")
        }
        _database = buffer.readLengthEncodedString().getOrThrow() {
            => InvalidPacketException("This packet is not a Field packet: read database failed")
        }
        _table = buffer.readLengthEncodedString().getOrThrow() {
            => InvalidPacketException("This packet is not a Field packet: read table failed")
        }
        _originalTable = buffer.readLengthEncodedString().getOrThrow() {
            => InvalidPacketException("This packet is not a Field packet: read original table failed")
        }
        _name = buffer.readLengthEncodedString().getOrThrow() {
            => InvalidPacketException("This packet is not a Field packet: read name failed")
        }
        _originalName = buffer.readLengthEncodedString().getOrThrow() {
            => InvalidPacketException("This packet is not a Field packet: read original name failed")
        }
        let single = Array<Byte>(1, repeat: 0)
        if (buffer.read(single) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read padding failed")
        }
        this._padding = single[0]
        let charset = Array<Byte>(2, repeat: 0)
        if (buffer.read(charset) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read charset failed")
        }
        _charset = Charset.of(UInt16.fromLittleEndian(charset))
        let fieldLength = Array<Byte>(4, repeat: 0)
        if (buffer.read(fieldLength) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read field length failed")
        }
        this._columnLength = UInt32.fromLittleEndian(fieldLength)
        if (buffer.read(single) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read field type failed")
        }
        this._columnType = ColumnType.of(single[0])
        let flags = Array<Byte>(2, repeat: 0)
        if (buffer.read(flags) == 0) {
            throw InvalidPacketException("This packet is not a Field packet: read flags failed")
        }
        this._flags = UInt16.fromLittleEndian(flags)
        if (buffer.read(single) == 0) {
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

    protected prop columnLength: UInt32 {
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
protected class TextResult <: CommonResponse {

    private var _values: Array<?Array<Byte>>

    protected prop row: Array<?Array<Byte>> {
        get() {
            _values.toArray()
        }
    }

    protected init(length: UInt32, buffer: ByteBuffer, columnCount: Int64) {
        super(length,buffer)
        var list = ArrayList<?Array<Byte>>(columnCount)
        for (_ in 0..columnCount) {
            list.append(buffer.readLengthEncodedStringRaw())
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

    protected init(length: UInt32, buffer: ByteBuffer, columnInfos: Array<ColumnDefinition>) {
        super(length, buffer)
        var columnCount = columnInfos.size
        var nullMap = Array<Byte>((columnCount + 7 + 2) / 8, repeat: 0)
        buffer.read(nullMap)
        _nullMap = nullMap
        _binaryData = Array<?Array<Byte>>(columnCount, repeat: [])
        for (i in 0..columnCount) {
            var isNull = (_nullMap[(i + 2) / 8] & (1u8 << ((i + 2) % 8))) != 0
            if (isNull) {
                _binaryData[i] = None
            } else {
                var columnInfo = columnInfos[i]
                var columnType = columnInfo.columnType
                match (columnType) {
                    case Tiny =>
                        let array = Array<Byte>(1, repeat: 0)
                        buffer.read(array)
                        _binaryData[i] = array
                    case Short | Year =>
                        let array = Array<Byte>(2, repeat: 0)
                        buffer.read(array)
                        _binaryData[i] = array
                    case Long | Int24 | Float =>
                        let array = Array<Byte>(4, repeat: 0)
                        buffer.read(array)
                        _binaryData[i] = array
                    case LongLong | Double =>
                        let array = Array<Byte>(8, repeat: 0)
                        buffer.read(array)
                        _binaryData[i] = array
                    case String | NewDecimal | Json | Enum | Set | TinyBlob | MediumBlob | LongBlob | Blob | VarString =>
                         _binaryData[i] = buffer.readLengthEncodedStringRaw()
                    case Date | DateTime | Timestamp | Time =>
                        let single = Array<Byte>(1, repeat: 0)
                        buffer.read(single)
                        let temp = Array<Byte>(Int64(single[0]), repeat: 0)
                        buffer.read(temp)
                        let list = ArrayList<Byte>(Int64(1 + single[0]))
                        list.appendAll(single)
                        list.appendAll(temp)
                        _binaryData[i] = list.toArray()
                    //case _ => throw Exception("Unsupport MySQL binary type")
                }
            }
        }
    }
}
