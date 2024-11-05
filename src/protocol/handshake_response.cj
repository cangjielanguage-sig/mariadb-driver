/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.collection.HashMap

/*
* HandshakeResponse41
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_handshake_response.html
*/
protected class HandshakeResponse <: Request {

    private var _capabilities: UInt32 = 0x00

    private var _maxPacket: UInt32 = 0x00

    private var _charset: Byte = 0x00

    private var _unused: Array<Byte> = Array<Byte>(23, repeat: 0)

    private var _username: String = ""

    private var _authResponse: Array<Byte> = []
    
    private var _schema: String = ""

    private var _clientAuthPlugin: String = ""

    private var _attribute: HashMap<String, String> = HashMap<String, String>()

    private var _zstdCompressionLevel: Byte = 0x00
    
    protected init(number: UInt8) {
        super(0, number)
    }
    
    protected func setNumber(number: UInt8): HandshakeResponse{
            this._number = number
            return this
    }

    protected func setMaxPacket(maxPacket: UInt32): HandshakeResponse {
        this._maxPacket = maxPacket
        return this
    }

    protected func setCharset(charset: Byte): HandshakeResponse {
        this._charset = charset
        return this
    }

    protected func setUsername(username: String): HandshakeResponse {
        this._username = username
        return this
    }

    protected func setAuthResponse(authResponse: Array<Byte>): HandshakeResponse {
        this._authResponse = authResponse
        return this
    }

    protected func setDatabase(database: String): HandshakeResponse {
        _schema = database
        return this
    }

    protected func setClientAuthPlugin(plugin: String): HandshakeResponse {
        this._clientAuthPlugin = plugin
        return this
    }

    protected func setAttrbiture(name: String, value: String): HandshakeResponse {
        this._attribute.put(name, value)
        return this
    }

    protected func setZstdCompressionLevel(level: Byte) {
        this._zstdCompressionLevel = level
        return this
    }

    protected func setCapability(capability: Capability): HandshakeResponse {
        _capabilities |= capability.value()
        return this
    }

    protected func hasCapability(capability: Capability): Bool{
        return (_capabilities & capability.value()) != 0
    }

    public override func pack(): Unit {
        var length: Int64 = 0
        //put packet length and number placeholer
        super.pack()
        //put client Capabilities
        buf.appendAll(_capabilities.toLittleEndian())
        length += 4
        //put max packet
        buf.appendAll(_maxPacket.toLittleEndian())
        length += 4
        //put charset
        buf.append(_charset)
        length += 1
        //put unused
        buf.appendAll(_unused)
        length += 23
        //put username
        let (uname, size) = toNullTerminated(_username)
        buf.appendAll(uname)
        length += size
        //put auth response
        if(hasCapability(PluginAuthLenencClientData)){
            buf.append(UInt8(_authResponse.size))
            length += 1
            buf.appendAll(_authResponse)
            length += _authResponse.size
        }else{
            buf.appendAll(_authResponse)
            length += _authResponse.size
        }
        // put schema if 'Connect With DB' are set
        if(hasCapability(ConnectWithDB)){
            let schema = _schema.toArray()
            buf.appendAll(schema)
            length += schema.size
            buf.append(0x00)
            length += 1
        }
        //put client auth plguin
        if(hasCapability(PluginAuth)){
            let pluginArray: Array<Byte> = _clientAuthPlugin.toArray()
            buf.appendAll(pluginArray)
            length += pluginArray.size
            buf.append(0x00)
            length += 1
        }
        //put attributes length placeholder
        if(hasCapability(ConnectAttrs)) {
            buf.append(0x00)
            var attrLenIndex: Int = length + HeaderSize
            length += 1
            var attrLen: Int = 0
            for((k,v) in _attribute){
                //put attr name length
                var name = k.toArray()
                buf.append(UInt8(name.size))
                attrLen++
                //put attr name
                buf.appendAll(name)
                attrLen += name.size
                //put attr value length
                buf.append(UInt8(v.toArray().size))
                attrLen++
                //put attr value
                var valueArr = v.toArray()
                buf.appendAll(valueArr)
                attrLen += valueArr.size
            }
            length += attrLen
            // set attribiters length
            buf.set(Int64(attrLenIndex), UInt8(attrLen))
        }

        if(hasCapability(ZSTDCompressionAlgorithm)) {
            buf.append(_zstdCompressionLevel)
            length += 1
        }
        // set packet length
        reset(UInt32(length))
    }

    /*
    * SSL Connection Request Packet.
    * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_ssl_request.html
    */
    protected func sslRequest(): Array<Byte> {
        var length: Int = 0
        super.pack()
        //put client Capabilities
        buf.appendAll(_capabilities.toLittleEndian())
        length += 4
        //put max packet
        buf.appendAll(_maxPacket.toLittleEndian())
        length += 4
        //put charset
        buf.append(_charset)
        length += 1
        //put unused
        buf.appendAll(_unused)
        length += 23
        reset(UInt32(length))
        return buf.toArray()
    }

    protected static func getDefault(number: UInt8): HandshakeResponse{
        return HandshakeResponse(number)
                            .setCapability(LongPassword)
                            .setCapability(LongFlags)
                            .setCapability(LocalFiles)
                            .setCapability(Protocol41)
                            .setCapability(Interactive)
                            .setCapability(Transactions)
                            .setCapability(MultiStatements)
                            .setCapability(MultiResults)
                            .setCapability(PsMultiResults)
                            .setCapability(PluginAuth)
                            .setCapability(ConnectAttrs)
                            .setCapability(PluginAuthLenencClientData)
                            .setCapability(CanHandleExpiredPasswords)
                            .setCapability(SessionTrack)
                            .setCapability(RememberOptions)
                            .setCapability(Reserved2)
                            //.setCapability(FoundRows)
                            //.setCapability(QueryAttributes)
                            .setCharset(33)
                            .setMaxPacket(1073741824)
    }
}

/*
 * 请求服务器公钥报文
 */
protected class RequestPublicKey <: Request{

    internal var _code: Byte = 0x02

    protected init(number: UInt8, code: Byte){
        super(1,number)
        _code = code
    }
    
    protected prop code: Byte{
        get() {
            return _code
        }
    }

    protected override func pack(): Unit {
        super.pack()
        buf.append(_code)
    }

}

/*
 * 密码报文
 */
protected class SendPassword <: Request{

    private var _authResponse: Array<Byte>

    protected init(number: UInt8,password: Array<Byte>){
        super(UInt32(password.size),number)
        this._authResponse = password
    }

    protected override func pack(): Unit {
        super.pack()
        buf.appendAll(_authResponse)
    }


}

