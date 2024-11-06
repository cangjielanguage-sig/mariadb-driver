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

    private var lastRemaining: Array<Byte> = []

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
        //尝试从上次剩余的数据读取下一个包的长度
        if(lastRemaining.size != 0) {
            if(lastRemaining.size >= 3) {
                header[0] = lastRemaining[0]
                header[1] = lastRemaining[1]
                header[2] = lastRemaining[2]
                lastRemaining = lastRemaining.slice(3, lastRemaining.size - 3)
            }else{
                if(lastRemaining.size == 1) {
                    header[0] = lastRemaining[0]
                    let temp = Array<Byte>(2, repeat: 0)
                    socket.read(temp)
                    header[1] = temp[0]
                    header[2] = temp[1]
                    lastRemaining = []
                } else {
                    header[0] = lastRemaining[0]
                    header[1] = lastRemaining[1]
                    let temp = Array<Byte>(1, repeat: 0)
                    socket.read(temp)
                    header[2] = temp[0]
                    lastRemaining = []
                }
            }
        }else{
            socket.read(header)
        }
        let subLength = UInt32.fromLittleEndian(header)
        let bufferSize = Int64(subLength) + 1
        let buffer = Array<Byte>(bufferSize, repeat: 0)
        readFully(buffer, 0, bufferSize)
        return (subLength, buffer)
    }

    private func readFully(buffer: Array<Byte>, offset: Int, len: Int): Int {
        if(len < 0) {
            throw IndexOutOfBoundsException()
        }
        var n = 0
        while(n < len) {
            let count = read(buffer, offset + n, len - n)
            if(count == 0) {
                continue
            }
            n += count
        }
        return n
    }


    private func read(buffer: Array<Byte>, offset: Int, len: Int): Int {
        if(buffer.size - offset < len) {
            throw IOException("buffer remaining size is not enough")
        }
        if(len == 0) {
            return 0
        }

        let buf = Array<Byte>(1024, repeat: 0) //缓冲区

        var i: Int = 0 //已经读取了的长度
        //检查上次是否剩余数据
        if(lastRemaining.size > 0) {
            if(lastRemaining.size > len) {
                //上次剩余的数据比这次要读取的数据多
                let remainingSize = lastRemaining.size - len
                lastRemaining.copyTo(buffer, 0, offset, len)
                lastRemaining = lastRemaining.slice(len, remainingSize)
                i += len
            }else {
                //上次剩余的数据比这次要少读取的数据或者相等
                lastRemaining.copyTo(buffer, 0, offset, lastRemaining.size)
                i += lastRemaining.size
                lastRemaining = []
            }
        }
        while (i < len) {
            var length = socket.read(buf)//实际读取的数据长度
            if(length == 0) {
                //读完了,返回
                break
            }
            if(i + length > len) {
                //数据读多了,切片
                let needSize = len - i
                let remainingSize = length - needSize
                lastRemaining = buf.slice(needSize, remainingSize)
                //拷贝需要的数据
                buf.copyTo(buffer, 0, offset + i, needSize)
                i += needSize
            }else {
                buf.copyTo(buffer, 0, offset + i, length)
                i += length
            }
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
     * flsuh buffer
     */
    protected func flush() {
        socket.flush()
    }


}