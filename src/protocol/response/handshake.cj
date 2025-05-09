/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mysql.protocol.response

import std.io.*
import std.collection.*
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

    protected prop capabilities: UInt32 {
        get() {
            let part1 = serverCapabilities.toLittleEndian()
            let part2 = extendedServerCapabilities.toLittleEndian()
            return UInt32.fromLittleEndian([part1[0], part1[1], part2[0], part2[1]])
        }
    }

    protected prop salt: Array<Byte> {
        get() {
            let buf = ArrayList<Byte>(salt1.size + salt2.size)
            buf.add(all: salt1)
            buf.add(all: salt2)
            return buf.toArray()
        }
    }

    protected prop authPlugin: String {
        get() {
            authenticationPlugin
        }
    }
    
    protected func hasCapability(capability: Capability): Bool {
        return (capabilities & capability.value()) != 0
    }

    protected init(length: UInt64, number: UInt8, buffer: ByteBuffer) {
        super(length, number)
        // 协议: 1 byte
        this.protocol = buffer.readFix1Integer()
        // 服务器版本: null end
        this.version = buffer.readNullTerminatedString()
        // 线程id: 4 byte
        this.threadId = buffer.readFix4Integer()
        // 随机盐: null end
        this.salt1 = buffer.readNullTerminatedStringRaw()
        // 服务器权能标志: 2 byte
        this.serverCapabilities = buffer.readFix2Integer()
        // 服务字符编码集: 1 byte
        this.serverLanguage = buffer.readFix1Integer()
        // 服务器状态: 2 byte
        this.serverStatus = buffer.readFix2Integer()
        // 服务器权能标志扩展: 2 byte
        this.extendedServerCapabilities = buffer.readFix2Integer()
        // 认证插件长度: 1 byte
        this.authenticationDataLength = buffer.readFix1Integer()
        // if(hasCapability(PluginAuth)){
        //     this.authenticationDataLength = buffer.readOneByte()
        // }else{
        //     this.authenticationDataLength = 0x00
        // }
        // 未使用: 10 byte
        let temp = Array<Byte>(10, repeat: 0)
        if(buffer.read(temp)  != 10) {
            throw InvalidPacketException()
        }
        // 随机盐: n byte
        this.salt2 = buffer.readNullTerminatedStringRaw()
        // 认证插件: n byte
        this.authenticationPlugin = buffer.readNullTerminatedString()
        // if(hasCapability(PluginAuth)){
        //     this.authenticationPlugin = buffer.readNullTerminatedString()
        // }
    }

}