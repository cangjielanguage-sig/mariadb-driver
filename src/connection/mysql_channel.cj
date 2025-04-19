/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.connection

import std.net.*
import mysql.util.*

/*
* mysql channl reads complete mysql packages from the socket
*/
protected class MySqlChannel <: Resource {

    private let header: Array<Byte> = Array<Byte>(3, repeat: 0)

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

    /*
     * read a mysql package from socket
     */
    protected func read(): (UInt32, Array<Byte>) {
        readFully(header)
        let length = UInt32.fromLittleEndian(header)                                  
        let b = Array<Byte>(Int64(length) + 1, repeat: 0)
        readFully(b)
        return (length, b)
    }

    private func readFully(b: Array<Byte>): Int {
        var i: Int = 0 //已经读取了的长度
        while(i < b.size) {
            let remaining = b.size - i
            var readed = 0
            if(remaining >= 1024) {
                readed = socket.read(buffer)
                buffer.copyTo(b, 0, i, readed)
            }else {
                let temp = Array<Byte>(remaining, repeat: 0)
                readed = socket.read(temp)
                temp.copyTo(b, 0, i, readed)
            }
            i += readed
        }
        return i
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