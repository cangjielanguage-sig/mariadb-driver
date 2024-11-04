/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.io.*
import std.collection.*
import std.binary.*


/*
* Initial handshake packet for protocol version 10.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_handshake_v10.html
*/
protected class Handshake <: CommonPacket {

    private var _protocol: Byte = 0x00

    private var _version: String = ""

    private var _threadId: UInt32 = 0x00

    private var _salt1: Array<Byte> = []

    private var _serverCapabilities: UInt16 = 0x00

    private var _serverLanguage: Byte = 0x00

    private var _serverStatus: UInt16 = 0x00

    private var _extendedServerCapabilities: UInt16 = 0x00

    private var _authenticationDataLength: Byte = 0x00

    private var _salt2: Array<Byte> = []

    private var _authenticationPlugin: String = ""

    protected prop capabilities: UInt32{
        get() {
            var part1 = Array<Byte>(2, repeat: 0)
            _serverCapabilities.writeLittleEndian(part1)
            var part2 = Array<Byte>(2, repeat: 0)
            _extendedServerCapabilities.writeLittleEndian(part2)
            return UInt32.fromLittleEndian([part1[0], part1[1], part2[0], part2[1]])
        }
    }

    protected prop salt: Array<Byte>{
        get() {
            var buf = ArrayList<Byte>()
            buf.appendAll(_salt1)
            buf.appendAll(_salt2)
            return buf.toArray()
        }
    }

    protected prop authPlugin: String{
        get() {
            _authenticationPlugin
        }
    }
    
    protected func hasCapability(capability: Capability): Bool{
        return (capabilities & capability.value()) != 0
    }

    protected init(stream: InputStream){
        super(stream)
        // 协议: 1 byte
        var protocol = Array<Byte>(1, repeat: 0)
        if(stream.read(protocol) == 0){
            throw InvalidPacketException("This packet is not a Handshake packet: read protocol failed")
        }
        this._protocol = protocol[0]
        // 服务器版本: n byte,以空字符结束
        var single = Array<Byte>(1, repeat: 0)
        var sversion = ArrayList<Byte>()
        do {
            if(stream.read(single) == 0){
                throw InvalidPacketException("This packet is not a Handshake packet: read version failed")
            }
            if(single[0] != 0){
                sversion.append(single[0])
            }
        } while (single[0] != 0)
        this._version = String.fromUtf8(sversion.toArray())
        // 线程id: 4 byte
        var threadId = Array<Byte>(4, repeat: 0)
        if(stream.read(threadId) == 0){
            throw InvalidPacketException("This packet is not a Handshake packet: read threadId failed")
        }
        this._threadId = UInt32.fromLittleEndian(threadId)
        // 随机盐: n byte,以空字符结束
        var salt1 = ArrayList<Byte>()
        do {
            if(stream.read(single) == 0){
                throw InvalidPacketException("This packet is not a Handshake packet: read first salt failed")
            }
            if(single[0] != 0){
                 salt1.append(single[0])
            }
        } while (single[0] != 0)
        this._salt1 = salt1.toArray()
        // 服务器权能标志: 2 byte
        var serverCapabilities = Array<Byte>(2, repeat: 0)
        if(stream.read(serverCapabilities) == 0){
            throw InvalidPacketException("This packet is not a Handshake packet: read server capabilities failed")
        }
        this._serverCapabilities = UInt16.fromLittleEndian(serverCapabilities)
        // 服务字符编码集: 1 byte
        var serverLanguage = Array<Byte>(1, repeat: 0)
        if(stream.read(serverLanguage) == 0){
            throw InvalidPacketException("This packet is not a Handshake packet: read server language failed")
        }
        this._serverLanguage = serverLanguage[0]
        // 服务器状态: 2 byte
        var serverStatus = Array<Byte>(2, repeat: 0)
        if(stream.read(serverStatus) == 0){
            throw InvalidPacketException("This packet is not a Handshake packet: read server status failed")
        }
        this._serverStatus = UInt16.fromLittleEndian(serverStatus)
        // 服务器权能标志扩展: 2 byte
        var extendedServerCapabilities = Array<Byte>(2, repeat: 0)
        if(stream.read(extendedServerCapabilities) == 0){
            throw InvalidPacketException("This packet is not a Handshake packet: read extended server capabilities failed")
        }
        this._extendedServerCapabilities = UInt16.fromLittleEndian(extendedServerCapabilities)
        // 认证插件长度: 1 byte
        if(hasCapability(PluginAuth)){
            var authenticationDataLength = Array<Byte>(1, repeat: 0)
            if(stream.read(authenticationDataLength) == 0){
                throw InvalidPacketException("This packet is not a Handshake packet: read length of authentication plugin name failed")
            }
            this._authenticationDataLength = authenticationDataLength[0]
        }else{
            this._authenticationDataLength = 0x00
        }
        // 未使用: 10 byte
        var unused = Array<Byte>(10, repeat: 0)
        if(stream.read(unused) == 0){
            throw InvalidPacketException("This packet is not a Handshake packet: read padding failed")
        }
        // 随机盐: n byte
        var salt2 = ArrayList<Byte>()
        do {
            if(stream.read(single) == 0){
                throw InvalidPacketException("This packet is not a Handshake packet: read second salt failed")
            }
            if(single[0] != 0){
                salt2.append(single[0])
            }
        } while (single[0] != 0)
        this._salt2 = salt2.toArray()
        // 认证插件: n byte
        if(hasCapability(PluginAuth)){
            var authenticationPlugin = ArrayList<Byte>()
            do {
                if(stream.read(single) == 0){
                    throw InvalidPacketException("This packet is not a Handshake packet: read second salt failed")
                }
                if(single[0] != 0){
                    authenticationPlugin.append(single[0])
                }
            } while (single[0] != 0)
            this._authenticationPlugin = String.fromUtf8(authenticationPlugin.toArray())
        }
    }

}