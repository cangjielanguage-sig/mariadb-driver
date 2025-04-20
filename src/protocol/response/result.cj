/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.response

import std.io.*
import mysql.util.*
import mysql.protocol.*
/*
 * Field Count packet
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response.html
 */
protected class ColumnCount <: CommonResponse {

    protected let count: UInt64

    protected init(length: UInt64, number: UInt8, buffer: ByteBuffer) {
        super(length, number)
        //列的数量: lenenc
        this.count = UInt64.fromLittleEndian(buffer.readLengthEncodedIntegerRaw().getOrThrow())
    }
}

/*
 * Column Definition
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response_text_resultset_column_definition.html
 */
protected class ColumnDefinition <: CommonResponse {
    /*目录名*/
    protected let catalog: String
    /*数据库名*/
    protected let database: String
    /*表名*/
    protected let table: String
    /*原始表名*/
    protected let originalTable: String
    /*字段名*/
    protected let name: String
    /*原始字段名*/
    protected let originalName: String
    /*填充值*/
    protected let padding: Byte
    /*字符串编码*/
    protected let charset: Charset
    /*字段长度*/
    protected let columnLength: UInt32
    /*字段类型*/
    protected let columnType: ColumnType
    /*字段标志*/
    protected let flags: UInt16
    /*浮点型精度*/
    protected let decimals: Byte

    protected init(length: UInt64, number: UInt8, buffer: ByteBuffer) {
        super(length, number)
        //目录名: lenenc
        this.catalog = buffer.readLengthEncodedString().getOrThrow()
        //数据库名: lenenc
        this.database = buffer.readLengthEncodedString().getOrThrow()
        //表别名: lenenc
        this.table = buffer.readLengthEncodedString().getOrThrow()
        //表名: lenenc
        this.originalTable = buffer.readLengthEncodedString().getOrThrow()
        //列别名: lenenc
        this.name = buffer.readLengthEncodedString().getOrThrow()
        //列名: lenenc
        this.originalName = buffer.readLengthEncodedString().getOrThrow()
        //保留位: 1 byte
        this.padding = buffer.readFix1Integer()
        //字符集: 2 byte
        this.charset = Charset.of(buffer.readFix2Integer())
        //字段最大长度: 4 byte
        this.columnLength = buffer.readFix4Integer()
        //列类型: 1 byte
        this.columnType = ColumnType.of(buffer.readFix1Integer())
        //列标志: 2 byte
        this.flags =buffer.readFix2Integer()
        //精度: 1 byte
        this.decimals = buffer.readFix1Integer()
    }

    protected func hasFlag(flag: ColumnFlag): Bool {
        (flags & flag.value()) != 0
    }
}

/*
 * Text Resultset Row Packet
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response_text_resultset_row.html
 */
protected class TextResult <: CommonResponse {

    protected let row: Array<?Array<Byte>>

    protected init(length: UInt64, number: UInt8, buffer: ByteBuffer, columnCount: Int64) {
        super(length, number)
        this.row = Array<?Array<Byte>>(columnCount, repeat: None)
        for(i in 0..columnCount) {
            row[i] = buffer.readLengthEncodedStringRaw()
        }
    }
}

/*
 * Binary Protocol Resultset
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html
 */
protected class BinaryResult <: Response {
    
    protected let nullMap: Array<Byte>

    protected let binaryData: Array<?Array<Byte>>

    protected init(length: UInt64, number: UInt8, buffer: ByteBuffer, columnInfos: Array<ColumnDefinition>) {
        super(length, number, buffer)
        let columnCount = columnInfos.size
        //null数据位图
        let size = (columnCount + 7 + 2) / 8
        let nullMap = Array<Byte>(size, repeat: 0)
        if(buffer.read(nullMap) != size) {
            throw InvalidPacketException()
        }
        this.nullMap = nullMap
        //二进制数据
        this.binaryData = Array<?Array<Byte>>(columnCount, repeat: [])
        for (i in 0..columnCount){
            let isNull = (nullMap[(i + 2) / 8] & (1u8 << ((i + 2) % 8))) != 0
            if (isNull) {
                binaryData[i] = None
            } else{
                let columnInfo = columnInfos[i] 
                let columnType = columnInfo.columnType
                match (columnType) {
                    case Tiny =>
                        binaryData[i] = buffer.readFix1IntegerRaw()
                    case Short | Year =>
                        binaryData[i] = buffer.readFix2IntegerRaw()
                    case Long | Int24 | Float =>
                        binaryData[i] = buffer.readFix4IntegerRaw()
                    case LongLong | Double =>
                        binaryData[i] = buffer.readFix8IntegerRaw()
                    case String | NewDecimal | Json | Enum | Set | TinyBlob | MediumBlob | LongBlob | Blob | VarString =>
                         binaryData[i] = buffer.readLengthEncodedStringRaw()
                    case Date | DateTime | Timestamp | Time =>
                        let flag = buffer.readFix1Integer()
                        let size = Int64(flag)
                        binaryData[i] = buffer.bytes().slice(0, Int64(size))
                        buffer.seek(Current(Int64(size)))
                    //case _ => throw Exception("Unsupport MySQL binary type")
                }
            }
        }
    }
}
