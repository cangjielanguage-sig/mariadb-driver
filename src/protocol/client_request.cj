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

import std.io.*

protected abstract class Request {

    private static let SINGLE_PACKAGE_MAX: Int64 = (1 << 24) - 1

    protected let buffer: ByteBuffer = ByteBuffer()

    protected var number: UInt8

    protected init(number: UInt8) {
        this.number = number
    }
    
    protected open func pack(): Unit
    
    protected func writeTo(outputStream: OutputStream): Unit {
        pack()
        let bytes = buffer.bytes()
        var size = bytes.size
        var i = 0u8
        //对超过16mb的数据包进行分包处理
        while (size > SINGLE_PACKAGE_MAX) {
            outputStream.write(UInt32(SINGLE_PACKAGE_MAX).toLittleEndian().slice(0, 3))
            outputStream.write(number + i)
            outputStream.write(bytes.slice(SINGLE_PACKAGE_MAX * Int64(i), SINGLE_PACKAGE_MAX))
            size -= SINGLE_PACKAGE_MAX
            i++
        }
        outputStream.write(UInt32(size).toLittleEndian().slice(0,3))
        outputStream.write(number + i)
        outputStream.write(bytes.slice(SINGLE_PACKAGE_MAX * Int64(i), size))
    }

}