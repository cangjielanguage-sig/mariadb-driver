/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.response

import std.io.*
import mysql.protocol.*
/*
* AuthMoreData Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_connection_phase_packets_protocol_auth_more_data.html
*/
protected open class AuthMoreData <: Response {

    /*
     * 认证响应数据: 可能是一个字节的数据,表示执行的是fast auth还是执行full auth
     * 也可能是执行full auth 返回的服务器公钥
     */
    internal var authRep: Array<Byte>

    internal init(length: UInt64, number: UInt8, buffer: ByteBuffer) {
        super(length, number, buffer)
        this.authRep = buffer.readFixedArray(Int64(length - 1))
    }

}

/*
* 公钥响应报文
*/
protected class PublicKeyResponse <: AuthMoreData {

    protected prop publicKey: String {
        get() {
            return String.fromUtf8(authRep)
        }
    }

    protected init(length: UInt64, number: UInt8, buffer: ByteBuffer) {
        super(length, number, buffer)
    }
}

/*
* 认证状态响应报文
*/
protected class AuthStatus <: AuthMoreData {

    protected prop state: AuthState {
        get() {
            AuthState.of(authRep[0])
        }
    }

    protected init(length: UInt64, number: UInt8, buffer: ByteBuffer) {
        super(length, number, buffer)
    }
    
}