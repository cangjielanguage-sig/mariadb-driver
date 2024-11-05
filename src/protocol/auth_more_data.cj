/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

import std.io.InputStream

/*
* AuthMoreData Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_auth_more_data.html
*/
protected open class AuthMoreData <: Response {

    /*
     * 认证响应数据: 可能是一个字节的数据,表示执行的是fast auth还是执行full auth
     * 也可能是执行full auth 返回的服务器公钥
     */
    internal var _authRep: Array<Byte>


    internal init(stream: InputStream){
        super(stream)
        var authReq = Array<Byte>(Int64(_length), repeat: 0)
        if(stream.read(authReq) == 0){
            throw InvalidPacketException("This packet is not a Auth Response packet: read auth response failed")
        }
        _authRep = authReq
    }

}

/*
* 公钥响应报文
*/
protected class PublicKeyResponse <: AuthMoreData {

    protected prop publicKey: String {
        get() {
            return String.fromUtf8(_authRep)
        }
    }

    protected init(stream: InputStream){
        super(stream)
    }
}

/*
* 认证状态响应报文
*/
protected class AuthStatus <: AuthMoreData {

    protected prop state: AuthState {
        get() {
            AuthState.get(_authRep[0])
        }
    }

    protected init(stream: InputStream){
        super(stream)
    }
    
}