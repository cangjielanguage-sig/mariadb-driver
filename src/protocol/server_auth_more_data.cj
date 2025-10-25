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
protected package mariadb.protocol

import std.io.*

protected open class AuthMoreData <: Response {

    /*
     * 认证响应数据: 可能是一个字节的数据,表示执行的是fast auth还是执行full auth
     * 也可能是执行full auth 返回的服务器公钥
     */
    internal var authRep: Array<Byte>

    internal init(length: UInt64, number: UInt8, buffer: ByteBuffer) {
        super(length, number, buffer)
        this.authRep = buffer.readArray(Int64(length - 1))
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