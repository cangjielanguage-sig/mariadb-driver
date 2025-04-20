/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.connection

import std.io.*
import std.net.*
import mysql.util.*

/*
* mysql channl reads complete mysql packages from the socket
*/
protected class MySqlChannel <: Resource {

    private static let SINGLE_PACKAGE_MAX: UInt64 = (1 << 24) - 1

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
        let bytes = ByteBuffer()
        var total = 0u64
        fillIn(length)
        fillIn(number)
        var len = UInt32.fromLittleEndian(length)
        var num = UInt8.fromLittleEndian(number)
        //对超过16mb的数据包进行整合                     
        while (UInt64(len) == SINGLE_PACKAGE_MAX) {
            fillIn(SINGLE_PACKAGE_MAX, bytes)
            total += UInt64(len)
            fillIn(length)
            fillIn(number)
            len = UInt32.fromLittleEndian(length)
            num = UInt8.fromLittleEndian(number)
        }
        fillIn(UInt64(len), bytes)
        total += UInt64(len)
        return (total, num, bytes)
    }

    private func fillIn(length: UInt64, dest: ByteBuffer) {
        var readed = 0u64
        while(readed < length) {
            let remaining = length - readed
            if(remaining >= UInt64(buffer.size)) {
                let len = socket.read(buffer)
                dest.write(buffer.slice(0, len))
                readed += UInt64(len)
            }else {
                let temp = Array<Byte>(Int64(remaining), repeat: 0)
                let len = socket.read(temp)
                dest.write(temp.slice(0, len))
                readed += UInt64(len)
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