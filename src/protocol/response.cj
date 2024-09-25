/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.protocol

import std.io.*
import std.collection.*

/*
* Generic Response Packets
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_response_packets.html
*/
protected open class Response <: CommonPacket {

    internal var _code: ResponseCode

    // internal prop code: ResponseCode {
    //     get() {
    //         return _code
    //     }
    // }

    internal init(stream: InputStream){
        super(stream)
        var single = Array<Byte>(1, repeat: 0)
        if(stream.read(single) == 0){
            throw InvalidPacketException("This packet is not a Response packet: read response code failed")
        }
        _code = ResponseCode.get(single[0])
    }
}

/*
* OK packet
* An OK packet is sent from the server to the client to signal successful completion of a command.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_ok_packet.html
*/
protected class OkResponse <: Response {

    private var _effectRows: UInt64

    private var _index: UInt64

    private var _serverStatus: UInt16

    private var _waringCount: UInt16

    private var _message: String

    protected prop message: String{
        get() {
            return _message
        }
    }

    protected prop effectRows: UInt64{
        get() {
            _effectRows
        }
    }

    protected prop index: UInt64{
        get() {
            _index
        }
    }

    protected init(stream: InputStream){
        super(stream)
        var effectRows = readLengthEncodedInteger(stream)
        if(effectRows.size == 0){
            throw InvalidPacketException("This packet is not a Ok Repsposne packet: read effect rows failed")
        }
        _effectRows = littleEndianToUInt64(effectRows)

        var index = readLengthEncodedInteger(stream)
        if(index.size == 0){
            throw InvalidPacketException("This packet is not a Ok Repsposne packet: read index failed")
        }
        _index = littleEndianToUInt64(index)
        var serverStatus = Array<Byte>(2, repeat: 0)
        if(stream.read(serverStatus) == 0){
            throw InvalidPacketException("This packet is not a Ok Repsposne packet: read server status failed")
        }
        _serverStatus = littleEndianToUInt16(serverStatus)

        var waringCount = Array<Byte>(2, repeat: 0)
        if(stream.read(waringCount) == 0){
            throw InvalidPacketException("This packet is not a Ok Repsposne packet: read waring count failed")
        }
        _waringCount = littleEndianToUInt16(waringCount)

        var message = Array<Byte>(Int64(_length - 5), repeat: 0)
        // if(stream.read(message) == 0){
        //     throw InvalidpacketException("This packet is not a Ok Repsposne packet: read message failed")
        // }
        _message = String.fromUtf8(message)
    }
}


/*
* Error Packet
* This packet signals that an error occurred.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_err_packet.html
*/
protected class ErrorResponse <: Response{

    private var _errorCode: UInt16

    private var _serverStatusFlag: Byte

    private var _sqlStatus: Array<Byte>

    private var _message: String

    protected init(stream: InputStream){
        super(stream)
        var errorCode = Array<Byte>(2,repeat: 0)
        if(stream.read(errorCode) == 0){
            throw InvalidPacketException("This packet is not a Error Repsposne packet: read error code failed")
        }
        _errorCode = littleEndianToUInt16(errorCode)
        var single = Array<Byte>(1,repeat: 0)
        if(stream.read(single) == 0){
            throw InvalidPacketException("This packet is not a Error Repsposne packet: read server status flag failed")
        }
        _serverStatusFlag = single[0]
        var sqlStatus = Array<Byte>(5, repeat: 0)
        if(stream.read(sqlStatus) == 0){
            throw InvalidPacketException("This packet is not a Error Repsposne packet: read sql status failed")
        }
        _sqlStatus = sqlStatus
        var message = Array<Byte>(Int64(_length - (8 + 1)), repeat: 0)
        if(stream.read(message) == 0){
            throw InvalidPacketException("This packet is not a Error Repsposne packet: read message failed")
        }
        _message = String.fromUtf8(message)
    }

    protected prop message: String {
        get() {
            _message
        }
    }
}

/*
* EOF packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_eof_packet.html
*/
protected open class AbstractEOF <: Response{

    internal init(stream: InputStream){
        super(stream)
    }
}

/*
* 切换认证方式响应报文
*/
protected class AuthSwitch <: AbstractEOF{

    private var _pluginName: String

    private var _salt: Array<Byte>

    protected init(stream: InputStream){
        super(stream)
        var single = Array<Byte>(1, repeat: 0)
        var pluginName = ArrayList<Byte>()
        if(stream.read(single) == 0){
            throw InvalidPacketException("This packet is not a Auth Switch Repsposne packet: read plugin name failed")
        }
        while(single[0] != 0){
            pluginName.append(single[0])
            if(stream.read(single) == 0){
                throw InvalidPacketException("This packet is not a Auth Switch Repsposne packet: read plugin name failed")
            }
        }
        _pluginName = String.fromUtf8(pluginName.toArray())
        var salt = ArrayList<Byte>()
        if(stream.read(single) == 0){
            throw InvalidPacketException("This packet is not a Auth Switch Repsposne packet: read plugin data failed")
        }
        while(single[0] != 0){
            salt.append(single[0])
            if(stream.read(single) == 0){
                throw InvalidPacketException("This packet is not a Auth Switch Repsposne packet: read plugin data failed")
            }
        }
        _salt= salt.toArray()
    }

    protected prop pluginName: String{
        get() {
            _pluginName
        }
    }
    protected prop salt: Array<Byte>{
        get() {
            _salt
        }
    }
}

/*
* 普通Eof响应报文
*/
protected class EofResponse <: AbstractEOF{

    private var _waringCount: UInt16

    private var _status: UInt16


    protected init(stream: InputStream){
        super(stream)
        var waringCount = Array<Byte>(2, repeat: 0)
        if(stream.read(waringCount) == 0){
            throw InvalidPacketException("This packet is not a Eof Resposne packet: read effect rows failed")
        }
        _waringCount = littleEndianToUInt16(waringCount)
        var status = Array<Byte>(2, repeat: 0)
        if(stream.read(status) == 0){
            throw InvalidPacketException("This packet is not a Eof Repsposne packet: read effect rows failed")
        }
        _status = littleEndianToUInt16(status)
    }

}

/*
* COM_STMT_PREPARE_OK
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_stmt_prepare.html#sect_protocol_com_stmt_prepare_response
*/
protected class PrepareResposne <: Response{

    private var _statementId: UInt32

    private var _numColumns: UInt16

    private var _numParams: UInt16

    private var _reserved: UInt8

    private var _warningCount: UInt16

    protected init(stream: InputStream){
        super(stream)
        var statementId = Array<Byte>(4, repeat: 0)
        if(stream.read(statementId) == 0){
            throw InvalidPacketException("This packet is not a PrepareOkResposnePacket: read statementId failed")
        }
        _statementId = littleEndianToUInt32(statementId)
        var numColumns = Array<Byte>(2, repeat: 0)
        if(stream.read(numColumns) == 0){
            throw InvalidPacketException("This packet is not a PrepareOkResposnePacket: read numColumns failed")
        }
        _numColumns = littleEndianToUInt16(numColumns)
        var numParams = Array<Byte>(2, repeat: 0)
        if(stream.read(numParams) == 0){
            throw InvalidPacketException("This packet is not a PrepareOkResposnePacket: read numParams failed")
        }
        _numParams = littleEndianToUInt16(numParams)
        _reserved = 0x00
        var warningCount = Array<Byte>(2, repeat: 0)
        if(stream.read(warningCount) == 0){
            throw InvalidPacketException("This packet is not a PrepareOkResposnePacket: read waringCount failed")
        }
        _warningCount = littleEndianToUInt16(warningCount)
    }

    protected prop statementId: UInt32{
        get() {
            _statementId
        }
    }

    protected prop numColumns: UInt16{
        get() {
            _numColumns
        }
    }

    protected prop numParams: UInt16{
        get() {
            _numParams
        }
    }

}