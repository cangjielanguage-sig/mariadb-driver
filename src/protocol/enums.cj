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


/*
 * 认证状态枚举
 */
protected enum AuthState {
    
    | FastAuthSuccess
    | PerformFullAuthentication

    public static func of(value: Byte): AuthState {
        match (value) {
            case 0x03 => FastAuthSuccess
            case 0x04 => PerformFullAuthentication
            case _ => throw IllegalArgumentException("Don't have this AuthState by value ${value}")
        }
    }

    public func value(): Byte {
        match (this) {
            case FastAuthSuccess => 0x03
            case performFullAuthentication => 0x04
        }
    }

    public operator func ==(right: AuthState): Bool {
        return right.value() == this.value()
    }
}

/*
 * 响应码枚举
 */
protected enum ResponseCode <: ToString {

    | Ok
    | AuthMoreData
    | Eof
    | Error

    public func value(): Byte {
        match (this) {
            case Ok => 0x00
            case AuthMoreData => 0x01
            case Eof => 0xFE
            case Error => 0xFF
        }
    }
    
    public static func of(value: Byte): ResponseCode {
        match (value) {
            case 0x00 => Ok
            case 0xFF => Error
            case 0xFE => Eof
            case 0x01 => AuthMoreData
            case _ => throw MariaException("Inexpect response code: ${value}")
        }
    }

    public operator func ==(right: ResponseCode): Bool {
        return right.value() == this.value()
    }

    public func toString(): String {
        match (this) {
            case Ok => "Ok"
            case Error => "Error"
            case Eof => "Eof"
            case AuthMoreData => "AuthMoreData"
        }
    }
}

protected enum CursorType {

    | NoCursor
    | ReadOnly
    | ForUpdate
    | Scrollable
    | ParameterCountAvailable

    internal func value(): Byte {
        match (this) {
            case NoCursor => 0x00
            case ReadOnly => 0x01
            case ForUpdate => 0x02
            case Scrollable => 0x04
            case ParameterCountAvailable => 0x08
        }
    }

    internal operator func ==(right: CursorType): Bool {
        return this.value() == right.value()
    }
}

protected enum StatementOption {

    | MultiStatementsOn
    | MultiStatementsOff

    internal func value(): UInt16 {
        match (this) {
            case MultiStatementsOn => 0x00
            case MultiStatementsOff => 0x01
        }
    }
}
