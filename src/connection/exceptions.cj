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
protected package mariadb.connection

import mariadb.protocol.*



/*
* 服务器响应Error异常,表示执行命令后服务器响应Error
*/
protected class ResponseErrorException <: MariaException {

    init() {
        super()
    }

    protected ResponseErrorException(message: String) {
        super(message)    
    }

    public func toString(): String {
        return "ResponseErrorException: ${message}"
    }

}

/*
*  连接失败异常
*/
protected class ConnectFailedException <: MariaException {

    init() {
        super()
    }

    protected ConnectFailedException(message: String) {
        super(message)    
    }

    public func toString(): String {
        return "ConnectFailedException: ${message}"
    }

}

/*
* 值转换异常
*/
protected class ValueConvertException <: Exception {
    init() {
       super()
    }

    init(message: String) {
        super(message)    
    }

}