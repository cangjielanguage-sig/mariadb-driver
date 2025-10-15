/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
protected package mysql.protocol

/*
* HandshakeResponse41
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_handshake_response.html
*/
protected class HandshakeResponse <: Request {

    private var capabilities: UInt32 = 0x00

    private var maxPacket: UInt32 = 0x00

    private var charset: Byte = 0x00

    private var unused: Array<Byte> = Array<Byte>(23, repeat: 0)

    private var username: String = ""

    private var authResponse: Array<Byte> = []
    
    private var schema: String = ""

    private var clientAuthPlugin: String = ""

    private var attributes: Array<(String, String)> = Array<(String, String)>()

    private var zstdCompressionLevel: Byte = 0x00
    
    protected init(number: UInt8) {
        super(number)
    }
    
    protected func setNumber(number: UInt8): HandshakeResponse{
        this.number = number
        return this
    }

    protected func setMaxPacket(maxPacket: UInt32): HandshakeResponse {
        this.maxPacket = maxPacket
        return this
    }

    protected func setCharset(charset: Byte): HandshakeResponse {
        this.charset = charset
        return this
    }

    protected func setUsername(username: String): HandshakeResponse {
        this.username = username
        return this
    }

    protected func setAuthResponse(authResponse: Array<Byte>): HandshakeResponse {
        this.authResponse = authResponse
        return this
    }

    protected func setDatabase(schema: String): HandshakeResponse {
        this.schema = schema
        return this
    }

    protected func setClientAuthPlugin(plugin: String): HandshakeResponse {
        this.clientAuthPlugin = plugin
        return this
    }

    protected func setAttrbiture(attributes: Array<(String, String)>): HandshakeResponse {
        this.attributes = attributes
        return this
    }

    protected func setZstdCompressionLevel(level: Byte) {
        this.zstdCompressionLevel = level
        return this
    }

    protected func setCapabilitys(capabilities: UInt32): HandshakeResponse {
        this.capabilities = capabilities
        return this
    }

    protected func setCapability(capability: Capability): HandshakeResponse {
        this.capabilities |= capability.value()
        return this
    }

    protected func hasCapability(capability: Capability): Bool{
        return (this.capabilities & capability.value()) != 0
    }

    public override func pack(): Unit {
        //put client Capabilities
        this.capabilities |> buffer.writeInt4
        //put max packet
        this.maxPacket |> buffer.writeInt4
        //put charset
        this.charset |> buffer.writeInt1
        //put unused
        this.unused |> buffer.writeArray
        //put username
        this.username |> buffer.writeNullTerminated
        //put auth response
        if(hasCapability(PluginAuthLenencClientData)) {
            this.authResponse |> buffer.writeLengthEncoded
        } else {
            UInt8(this.authResponse.size) |> buffer.writeInt1
            this.authResponse |> buffer.writeLengthEncoded
        }
        // put schema if 'Connect With DB' are set
        if(hasCapability(ConnectWithDB)) {
            this.schema |> buffer.writeNullTerminated
        }
        //put client auth plguin
        if(hasCapability(PluginAuth)) {
            this.clientAuthPlugin |> buffer.writeNullTerminated
        }
        //put attributes
        if(hasCapability(ConnectAttrs)) {
            var size = 0
            for((k,v) in this.attributes) {
                size += k.toArray().size + 1
                size += v.toArray().size + 1
            }
            UInt64(size) |> buffer.writeLengthEncoded
            for((k,v) in this.attributes) {
                k |> buffer.writeNullTerminated
                v |> buffer.writeNullTerminated
            }
        }
        if(hasCapability(ZSTDCompressionAlgorithm)) {
            this.zstdCompressionLevel |> buffer.writeInt1
        }
        
    }

    protected func sslRequest(): Request {
        let ssl = SslRequeset(number)
        ssl.capabilities = capabilities
        ssl.maxPacket = maxPacket
        ssl.charset = charset
        return ssl
    }

    protected static func getDefault(number: UInt8): HandshakeResponse{
        return HandshakeResponse(number)
                            .setCapabilitys(DefaultCapability.default)
                            .setCharset(33)
                            .setMaxPacket(1073741824)
    }

}

/*
* SSL Connection Request Packet.
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_ssl_request.html
*/
protected class SslRequeset <: Request {

    protected var capabilities: UInt32 = 0x00

    protected var maxPacket: UInt32 = 0x00

    protected var charset: Byte = 0x00

    protected var unused: Array<Byte> = Array<Byte>(23, repeat: 0)

    protected init(number: UInt8) {
        super(number)
    }

    public override func pack(): Unit {
        //put client Capabilities
        this.capabilities |> buffer.writeInt4
        //put max packet
        this.maxPacket |> buffer.writeInt4
        //put charset
        this.charset |> buffer.write
        //put unused
        this.unused |> buffer.write
    }

}


/*
 * 请求服务器公钥报文
 */
protected class RequestPublicKey <: Request {

    protected let code: Byte

    protected init(number: UInt8, code: Byte) {
        super(number)
        this.code = code
    }

    protected override func pack(): Unit {
        this.code |> buffer.write
    }

}

/*
 * 密码报文
 */
protected class SendPassword <: Request {

    private let authResponse: Array<Byte>

    protected init(number: UInt8, password: Array<Byte>) {
        super(number)
        this.authResponse = password
    }

    protected override func pack(): Unit {
        this.authResponse |> buffer.write
    }

}

