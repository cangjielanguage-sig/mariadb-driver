/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.connection


import std.io.IOException
import std.collection.ArrayList
import std.net.TcpSocket
import std.net.StreamingSocket
import mysqlclient4cj.protocol.LittleEndian

/*
* mysql channl reads complete mysql packages from the socket
*/
protected class MySqlChannel <: Resource {

    private let header: Array<Byte> = Array<Byte>(3, repeat: 0)

    private let buffer = Array<Byte>(1024, repeat: 0)

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
        readFully(header, 0, 3)
        let length = UInt32.fromLittleEndian(header)                                  
        let bufferSize = Int64(length) + 1
        let b = Array<Byte>(bufferSize, repeat: 0)
        readFully(b, 0, bufferSize)
        return (length, b)
    }

    private func readFully(b: Array<Byte>, offset: Int, len: Int): Int {
        if(len == 0) {
            return 0
        }
        if(b.size - offset < len) {
            throw IOException("remaining size of buffer array is not enough")
        }
        var i: Int = 0 //已经读取了的长度
        while(i < len) {
            let remaining = len - i
            var readed = 0
            if(remaining >= 1024) {
                readed = socket.read(buffer)
                buffer.copyTo(b, 0, offset + i, readed)
            }else {
                let temp = Array<Byte>(remaining, repeat: 0)
                readed = socket.read(temp)
                temp.copyTo(b, 0, offset + i, readed)
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