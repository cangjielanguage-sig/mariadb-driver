/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol.response

import std.io.ByteBuffer
import std.collection.ArrayList
import mysql.protocol.*
/*
 * Field Count packet
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response.html
 */
protected class ColumnCount <: CommonResponse {

    protected let count: UInt64

    protected init(length: UInt32, buffer: ByteBuffer) {
        super(length, buffer) 
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

    protected init(length: UInt32, buffer: ByteBuffer) {
        super(length, buffer)
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
        this.padding = buffer.readOneByte()
        //字符集: 2 byte
        this.charset = Charset.of(UInt16.fromLittleEndian(buffer.readBytes(2)))
        //字段最大长度: 4 byte
        this.columnLength = UInt32.fromLittleEndian(buffer.readBytes(4))
        //列类型: 1 byte
        this.columnType = ColumnType.of(buffer.readOneByte())
        //列标志: 2 byte
        this.flags = UInt16.fromLittleEndian(buffer.readBytes(2))
        //精度: 1 byte
        this.decimals = buffer.readOneByte()
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

    protected init(length: UInt32, buffer: ByteBuffer, columnCount: Int64) {
        super(length, buffer)
        let columns = ArrayList<?Array<Byte>>(columnCount)
        for (_ in 0..columnCount) {
            columns.append(buffer.readLengthEncodedStringRaw())
        }
        this.row = columns.toArray()
    }
}

/*
 * Binary Protocol Resultset
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_binary_resultset.html
 */
protected class BinaryResult <: Response {
    
    protected let nullMap: Array<Byte>

    protected let binaryData: Array<?Array<Byte>>

    protected init(length: UInt32, buffer: ByteBuffer, columnInfos: Array<ColumnDefinition>) {
        super(length, buffer)
        let columnCount = columnInfos.size
        //null数据位图
        this.nullMap = buffer.readBytes((columnCount + 7 + 2) / 8)
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
                        binaryData[i] = buffer.readBytes(1)
                    case Short | Year =>
                        binaryData[i] = buffer.readBytes(2)
                    case Long | Int24 | Float =>
                        binaryData[i] = buffer.readBytes(4)
                    case LongLong | Double =>
                        binaryData[i] = buffer.readBytes(8)
                    case String | NewDecimal | Json | Enum | Set | TinyBlob | MediumBlob | LongBlob | Blob | VarString =>
                         binaryData[i] = buffer.readLengthEncodedStringRaw()
                    case Date | DateTime | Timestamp | Time =>
                        let flag = buffer.readOneByte()
                        let temp = buffer.readBytes(Int64(flag))
                        let list = ArrayList<Byte>(Int64(1 + flag))
                        list.append(flag)
                        list.appendAll(temp)
                        binaryData[i] = list.toArray()
                    //case _ => throw Exception("Unsupport MySQL binary type")
                }
            }
        }
    }
}
