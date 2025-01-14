/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol.response

import std.io.ByteBuffer
import std.collection.ArrayList
import mysql.protocol.*
/*
* Initial handshake packet for protocol version 10.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_handshake_v10.html
*/
protected class Handshake <: CommonResponse {

    protected let protocol: Byte

    protected let version: String

    protected let threadId: UInt32

    protected let salt1: Array<Byte>

    protected let serverCapabilities: UInt16

    protected let serverLanguage: Byte

    protected let serverStatus: UInt16

    protected let extendedServerCapabilities: UInt16 

    protected let authenticationDataLength: Byte

    protected let salt2: Array<Byte>

    protected let authenticationPlugin: String

    protected prop capabilities: UInt32{
        get() {
            let part1 = serverCapabilities.toLittleEndian()
            let part2 = extendedServerCapabilities.toLittleEndian()
            return UInt32.fromLittleEndian([part1[0], part1[1], part2[0], part2[1]])
        }
    }

    protected prop salt: Array<Byte>{
        get() {
            let buf = ArrayList<Byte>(salt1.size + salt2.size)
            buf.add(all: salt1)
            buf.add(all: salt2)
            return buf.toArray()
        }
    }

    protected prop authPlugin: String{
        get() {
            authenticationPlugin
        }
    }
    
    protected func hasCapability(capability: Capability): Bool{
        return (capabilities & capability.value()) != 0
    }

    protected init(length: UInt32, buffer: ByteBuffer){
        super(length, buffer)
        // 协议: 1 byte
        this.protocol = buffer.readOneByte()
        // 服务器版本: null end
        this.version = buffer.readNullTerminatedString()
        // 线程id: 4 byte
        this.threadId = UInt32.fromLittleEndian(buffer.readBytes(4))
        // 随机盐: null end
        this.salt1 = buffer.readNullTerminatedStringRaw()
        // 服务器权能标志: 2 byte
        this.serverCapabilities = UInt16.fromLittleEndian(buffer.readBytes(2))
        // 服务字符编码集: 1 byte
        this.serverLanguage = buffer.readOneByte()
        // 服务器状态: 2 byte
        this.serverStatus = UInt16.fromLittleEndian(buffer.readBytes(2))
        // 服务器权能标志扩展: 2 byte
        this.extendedServerCapabilities = UInt16.fromLittleEndian(buffer.readBytes(2))
        // 认证插件长度: 1 byte
        this.authenticationDataLength = buffer.readOneByte()
        // if(hasCapability(PluginAuth)){
        //     this.authenticationDataLength = buffer.readOneByte()
        // }else{
        //     this.authenticationDataLength = 0x00
        // }
        // 未使用: 10 byte
        buffer.readBytes(10)
        // 随机盐: n byte
        this.salt2 = buffer.readNullTerminatedStringRaw()
        // 认证插件: n byte
        this.authenticationPlugin = buffer.readNullTerminatedString()
        // if(hasCapability(PluginAuth)){
        //     this.authenticationPlugin = buffer.readNullTerminatedString()
        // }
    }

}