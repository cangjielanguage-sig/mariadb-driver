/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol.response

import std.io.ByteBuffer
import std.collection.ArrayList
import mysqlclient4cj.protocol.*

/*
* Generic Response Packets
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_response_packets.html
*/
protected open class Response <: CommonResponse {

    protected let code: ResponseCode

    protected init(length: UInt32, buffer: ByteBuffer){
        super(length, buffer)
        code = ResponseCode.get(buffer.readOneByte())
    }
}

/*
* OK packet
* An OK packet is sent from the server to the client to signal successful completion of a command.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_ok_packet.html
*/
protected class OkResponse <: Response {

    protected let effectRows: UInt64

    protected let index: UInt64

    protected let serverStatus: UInt16

    protected let waringCount: UInt16

    //protected let message: String

    //protected let sessionInfo: String

    protected init(length: UInt32, buffer: ByteBuffer) {
        super(length, buffer)
        //受影响的行: lenenc byte
        this.effectRows = UInt64.fromLittleEndian(buffer.readLengthEncodedIntegerRaw().getOrThrow())
        //最后一个插入的ID: lenenc byte
        this.index = UInt64.fromLittleEndian(buffer.readLengthEncodedIntegerRaw().getOrThrow())
        //服务器状态: 2 byte
        this.serverStatus = UInt16.fromLittleEndian(buffer.readBytes(2))
        //警告数量: 2 byte
        this.waringCount = UInt16.fromLittleEndian(buffer.readBytes(2))
        //this.message = ""
        //this.sessionInfo = ""
        // if(DefaultCapability.has(SessionTrack)) {
        //     this.message = buffer.readLengthEncodedString().getOrThrow()
        //     if(hasStatus(SessionStateChanged)) {
        //         this.sessionInfo = buffer.readLengthEncodedString().getOrThrow()
        //     }
        // }else {
        //     message = String.fromUtf8(buffer.readBytes(Int64(length - 5)))
        // }
        
    }

    protected func hasStatus(status: ServerStatus): Bool {
        return (serverStatus & status.value()) != 0
    }
}


/*
* Error Packet
* This packet signals that an error occurred.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_err_packet.html
*/
protected class ErrorResponse <: Response{

    protected let errorCode: UInt16

    protected let serverStatusFlag: Byte

    protected let sqlStatus: Array<Byte>

    protected let message: String

    protected init(length: UInt32,buffer: ByteBuffer){
        super(length, buffer)
        //错误代码: 2 byte
        this.errorCode = UInt16.fromLittleEndian(buffer.readBytes(2))
        //SQL状态标记: 1 byte
        this.serverStatusFlag = buffer.readOneByte()
        //SQL状态: 5 byte
        this.sqlStatus = buffer.readBytes(5)
        //错误信息: rest byte
        this.message = String.fromUtf8(buffer.readBytes(Int64(length - 9)))
    }

}

/*
* EOF packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_eof_packet.html
*/
protected open class AbstractEOF <: Response{

    protected init(length: UInt32, buffer: ByteBuffer){
        super(length, buffer)
    }
}

/*
* 切换认证方式响应报文
*/
protected class AuthSwitch <: AbstractEOF{

    protected let pluginName: String

    protected let salt: Array<Byte>

    protected init(length: UInt32, buffer: ByteBuffer){
        super(length, buffer)
        //插件名称: null end
        this.pluginName = buffer.readNullTerminatedString()
        //插件提供的数据: null end
        this.salt= buffer.readNullTerminatedStringRaw()
    }

}

/*
* 普通Eof响应报文
*/
protected class EofResponse <: AbstractEOF{

    protected let waringCount: UInt16

    protected let status: UInt16

    protected init(length: UInt32, buffer: ByteBuffer){
        super(length, buffer)
        //警告数量: 2 byte
        this.waringCount = UInt16.fromLittleEndian(buffer.readBytes(2))
        //状态标志
        this.status = UInt16.fromLittleEndian(buffer.readBytes(2))
    }

}

/*
* COM_STMT_PREPARE_OK
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_prepare.html#sect_protocol_com_stmt_prepare_response
*/
protected class PrepareResposne <: Response{

    protected let statementId: UInt32

    protected let numColumns: UInt16

    protected let numParams: UInt16

    protected let reserved: UInt8

    protected let warningCount: UInt16

    protected init(length: UInt32, buffer: ByteBuffer){
        super(length, buffer)
        //语句id: 4 byte
        this.statementId = UInt32.fromLittleEndian(buffer.readBytes(4))
        //列的数量: 2 byte
        this.numColumns = UInt16.fromLittleEndian(buffer.readBytes(2))
        //参数的数量: 2 byte
        this.numParams = UInt16.fromLittleEndian(buffer.readBytes(2))
        //保留位: 1 byte
        this.reserved = 0x00
        //警告数量
        if(length > 12) {
            this.warningCount = UInt16.fromLittleEndian(buffer.readBytes(2))
        }else {
            this.warningCount = 0
        }
    }

}