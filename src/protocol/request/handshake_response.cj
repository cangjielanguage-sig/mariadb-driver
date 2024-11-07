/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol.request

import std.collection.HashMap
import std.collection.ArrayList
import mysqlclient4cj.protocol.*
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

    private var attributes: HashMap<String, String> = HashMap<String, String>()

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

    protected func addAttrbiture(name: String, value: String): HandshakeResponse {
        this.attributes.put(name, value)
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
        //put packet length and number placeholer
        super.pack()
        //put client Capabilities
        buf.appendAll(capabilities.toLittleEndian())
        //put max packet
        buf.appendAll(maxPacket.toLittleEndian())
        //put charset
        buf.append(charset)
        //put unused
        buf.appendAll(unused)
        //put username
        buf.appendAll(username.toNullTerminated())
        //put auth response
        if(hasCapability(PluginAuthLenencClientData)){
            buf.appendAll(authResponse.toLengthEncoded())
        }else{
            buf.append(UInt8(authResponse.size))
            buf.appendAll(authResponse.toLengthEncoded())
        }
        // put schema if 'Connect With DB' are set
        if(hasCapability(ConnectWithDB)){
            buf.appendAll(schema.toNullTerminated())
        }
        //put client auth plguin
        if(hasCapability(PluginAuth)){
            buf.appendAll(clientAuthPlugin.toNullTerminated())
        }
        //put attributes
        if(hasCapability(ConnectAttrs)) {
            let temp = ArrayList<Byte>()
            for((k,v) in attributes) {
                let key = k.toNullTerminated()
                temp.appendAll(key)
                let value = v.toNullTerminated()
                temp.appendAll(value)
            }
            buf.appendAll(UInt64(temp.size).toLengthEncoded())
            buf.appendAll(temp)
        }
        if(hasCapability(ZSTDCompressionAlgorithm)) {
            buf.append(zstdCompressionLevel)
        }
    }

    /*
    * SSL Connection Request Packet.
    * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_ssl_request.html
    */
    protected func sslRequest(): Array<Byte> {
        super.pack()
        //put client Capabilities
        buf.appendAll(capabilities.toLittleEndian())
        //put max packet
        buf.appendAll(maxPacket.toLittleEndian())
        //put charset
        buf.append(charset)
        //put unused
        buf.appendAll(unused)
        setHeader()
        return buf.toArray()
    }

    protected static func getDefault(number: UInt8): HandshakeResponse{
        return HandshakeResponse(number)
                            .setCapabilitys(DefaultCapability.default)
                            .setCharset(33)
                            .setMaxPacket(1073741824)
    }
}

/*
 * 请求服务器公钥报文
 */
protected class RequestPublicKey <: Request{

    protected let code: Byte

    protected init(number: UInt8, code: Byte){
        super(number)
        this.code = code
    }

    protected override func pack(): Unit {
        super.pack()
        buf.append(code)
    }

}

/*
 * 密码报文
 */
protected class SendPassword <: Request{

    private var authResponse: Array<Byte>

    protected init(number: UInt8, password: Array<Byte>){
        super(number)
        this.authResponse = password
    }

    protected override func pack(): Unit {
        super.pack()
        buf.appendAll(authResponse)
    }


}

