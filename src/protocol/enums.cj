/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol


/*
 * 认证状态枚举
 */
protected enum AuthState {
    
    | FastAuthSuccess
    | PerformFullAuthentication

    public static func of(value: Byte): AuthState {
        match (value) {
            case 0x03 => return FastAuthSuccess
            case 0x04 => return PerformFullAuthentication
            case _ => throw IllegalArgumentException("Don't have this AuthState by value ${value}")
        }
    }

    public func value(): Byte {
        match (this) {
            case FastAuthSuccess => return 0x03
            case performFullAuthentication => return 0x04
        }
    }

    public operator func ==(right: AuthState): Bool {
        return right.value() == this.value()
    }
}

/*
 * 响应码枚举
 */
protected enum ResponseCode {

    | Ok
    | AuthMoreData
    | Eof
    | Error

    public func value(): Byte {
        match (this) {
            case Ok => return 0x00
            case AuthMoreData => return 0x01
            case Eof => return 0xFE
            case Error => return 0xFF
        }
    }
    public static func of(value: Byte): ResponseCode {
        match (value) {
            case 0x00 => return Ok
            case 0xFF => return Error
            case 0xFE => return Eof
            case 0x01 => return AuthMoreData
            case _ => throw Exception("Don't have this ResponseCode by value: ${value}")
        }
    }

    public operator func ==(right: ResponseCode): Bool {
        return right.value() == this.value()
    }
}

/*
 * The flags used in COM_STMT_EXECUTE.
 * referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/mysql__com_8h.html#a3e5e9e744ff6f7b989a604fd669977da
 */
protected enum CursorType {

    | NoCursor
    | ReadOnly
    | ForUpdate
    | Scrollable
    | ParameterCountAvailable

    internal func value(): Byte {
        match (this) {
            case NoCursor => return 0x00
            case ReadOnly => return 0x01
            case ForUpdate => return 0x02
            case Scrollable => return 0x04
            case ParameterCountAvailable => return 0x08
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
            case MultiStatementsOn => return 0x00
            case MultiStatementsOff => return 0x01
        }
    }
}
