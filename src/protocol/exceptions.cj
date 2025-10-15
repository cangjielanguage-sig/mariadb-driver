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


protected open class MySqlException <: Exception & ToString {

    protected init() {
       super()
    }

    protected init(message: String) {
        super(message)    
    }

    public open func toString(): String {
        return "MySqlException: ${message}"
    }

}


/*
* 无效数据包异常类,表示数据包解析异常
*/
protected class InvalidPacketException <: MySqlException {

    init() {
       super()
    }

    protected init(message: String) {
        super(message)    
    }

    public func toString(): String {
        return "InvalidPacketException: ${message}"
    }

}
