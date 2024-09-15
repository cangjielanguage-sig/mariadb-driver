/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.protocol

import std.collection.*

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

    private var _password: Array<Byte> = []
    
    private var _schema: String = ""

    private var _clientAuthPlugin: String = ""

    private var _attribute: Map<String, String> = HashMap<String, String>()

    
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

    protected func setPassword(password: Array<Byte>): HandshakeResponse {
        this._password = password
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

    protected func setCapability(capability: Capability): HandshakeResponse {
        _capabilities |= capability.value()
        return this
    }

    protected func hasCapability(capability: Capability): Bool{
        return (_capabilities & capability.value()) != 0
    }

    public override func toByteArray(): Array<Byte> {
        var arrayList = ArrayList<Byte>()
        var length: UInt32 = UInt32(HEADER_SIZE)
        //put packet length and number placeholer
        arrayList.appendAll(super.toByteArray())
        //put client Capabilities
        arrayList.appendAll(uInt32ToLittleEndian(_capabilities))
        length += 4
        //put max packet
        arrayList.appendAll(uInt32ToLittleEndian(_maxPacket))
        length += 4
        //put charset
        arrayList.append(_charset)
        length += 1
        //put unused
        arrayList.appendAll(_unused)
        length += 23
        //put username
        var unameArray: Array<Byte> = _username.toArray()
        arrayList.appendAll(unameArray)
        arrayList.append(0x00)
        length += UInt32(unameArray.size)
        length += 1
        //put password
        arrayList.append(UInt8(_password.size))
        length += 1
        arrayList.appendAll(_password)
        length += UInt32(_password.size)
        // put schema if 'Connect With DB' are set
        if(hasCapability(ConnectWithDB)){
            var schema = _schema.toArray()
            arrayList.appendAll(schema)
            length += UInt32(schema.size)
            arrayList.append(0x00)
            length += 1
        }
        //put client auth plguin
        var pluginArray: Array<Byte> = _clientAuthPlugin.toArray()
        arrayList.appendAll(pluginArray)
        //arrayList.append(0x00)
        length += UInt32(pluginArray.size)
        arrayList.append(0x00)
        length += 1
        //put attributes length placeholder
        if(getDefault(0).hasCapability(ConnectAttrs)) {
            arrayList.append(0x00)
            var attrLenIndex: UInt32  = length
            length += 1
            var attrLen: UInt8 = 0
            for((k,v) in _attribute){
                //put attr name length
                var name = k.toArray()
                arrayList.append(UInt8(name.size))
                attrLen++
                //put attr name
                arrayList.appendAll(name)
                attrLen += UInt8(name.size)
                //put attr value length
                arrayList.append(UInt8(v.toArray().size))
                attrLen++
                //put attr value
                var valueArr = v.toArray()
                arrayList.appendAll(valueArr)
                attrLen += UInt8(valueArr.size)
            }
            length += UInt32(attrLen)
            // set attribiters length
            arrayList.set(Int64(attrLenIndex), attrLen)
        }
        // set packet length
        var array: Array<Byte> = uInt32ToLittleEndian(UInt32(length) - UInt32(HEADER_SIZE))
        arrayList.set(0, array[0])
        arrayList.set(1, array[1])
        arrayList.set(2, array[2])
        return arrayList.toArray()
    }

    /*
    * SSL Connection Request Packet.
    * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_ssl_request.html
    */
    protected func sslRequest(): Array<Byte>{
        var arrayList = ArrayList<Byte>()
        var length: UInt32 = UInt32(HEADER_SIZE)
        //put packet length and number placeholer
        arrayList.appendAll(super.toByteArray())
        //put client Capabilities
        arrayList.appendAll(uInt32ToLittleEndian(_capabilities))
        length += 4
        //put max packet
        arrayList.appendAll(uInt32ToLittleEndian(_maxPacket))
        length += 4
        //put charset
        arrayList.append(_charset)
        length += 1
        //put unused
        arrayList.appendAll(_unused)
        length += 23
        var array: Array<Byte> = uInt32ToLittleEndian(UInt32(length) - UInt32(HEADER_SIZE))
        arrayList.set(0, array[0])
        arrayList.set(1, array[1])
        arrayList.set(2, array[2])
        return arrayList.toArray()
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

    protected override func toByteArray(): Array<Byte>{
        var appender = ArrayList<Byte>()
        appender.appendAll(super.toByteArray())
        appender.append(_code)
        return appender.toArray()
    }

}

/*
 * 密码报文
 */
protected class SendPassword <: Request{

    private var _password: Array<Byte>

    protected init(number: UInt8,password: Array<Byte>){
        super(UInt32(password.size),number)
        this._password = password
    }

    protected override func toByteArray(): Array<Byte>{
        var appender = ArrayList<Byte>()
        appender.appendAll(super.toByteArray())
        appender.appendAll(_password)
        return appender.toArray()
    }

}

