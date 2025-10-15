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
protected package mysql.connection

import std.io.*
import std.net.*
import mysql.protocol.*

/*
* mysql channl reads complete mysql packages from the socket
*/
protected class MySqlChannel <: Resource {

    private static let MAX_PACKAEG_SIZE: Int64 = (1 << 24) - 1

    private let length: Array<Byte> = Array<Byte>(3, repeat: 0)

    private let number: Array<Byte> = Array<Byte>(1, repeat: 0)

    private let buffer: Array<Byte> = Array<Byte>(1024, repeat: 0)

    protected var socket: StreamingSocket

    protected init(socket: TcpSocket) {
        this.socket = socket
    }

    public override func close() {
        socket.close()
    }

    public override func isClosed(): Bool {
        return socket.isClosed()
    }

    protected func read(): (UInt64, UInt8, ByteBuffer) {
        var total = 0
        fillIn(length)
        fillIn(number)
        var len = UInt32.fromLittleEndian(length)
        var num = UInt8.fromLittleEndian(number)
        let bytes = ByteBuffer(Int64(len))
        //对超过16mb的数据包进行整合                     
        while (Int64(len) == MAX_PACKAEG_SIZE) {
            fillIn(MAX_PACKAEG_SIZE, bytes)
            total += Int64(len)
            fillIn(length)
            fillIn(number)
            len = UInt32.fromLittleEndian(length)
            num = UInt8.fromLittleEndian(number)
        }
        fillIn(Int64(len), bytes)
        total += Int64(len)
        return (UInt64(total), num, bytes)
    }

    private func fillIn(length: Int64, dest: ByteBuffer) {
        var readed = 0
        while(readed < length) {
            let remaining = length - readed
            if(remaining >= Int64(buffer.size)) {
                let len = socket.read(buffer)
                dest.write(buffer.slice(0, len))
                readed += Int64(len)
            }else {
                let temp = Array<Byte>(Int64(remaining), repeat: 0)
                let len = socket.read(temp)
                dest.write(temp.slice(0, len))
                readed += Int64(len)
            }
        }
    }

    private func fillIn(b: Array<Byte>) {
        var readed = 0i64
        while(readed < b.size) {
            let remaining = b.size - readed
            if(remaining >= buffer.size) {
                let len = socket.read(buffer)
                buffer.copyTo(b, 0, readed, len)
                readed += len 
            } else {
                let temp = Array<Byte>(remaining, repeat: 0)
                let len = socket.read(temp)
                temp.copyTo(b, 0, readed, len)
                readed += len
            }
        }
    }

    /*
     * write a mysql package to socket
     */
    protected func write(data: Array<Byte>) {
        socket.write(data)
    }

    /*
     * flsuh b
     */
    protected func flush() {
        socket.flush()
    }


}