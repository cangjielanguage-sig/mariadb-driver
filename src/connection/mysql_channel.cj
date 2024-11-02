protected package mysqlclient4cj.connection

import std.net.*
import std.io.IOException
import std.collection.ArrayList
import mysqlclient4cj.protocol.littleEndianToUInt32

/*
* mysql channl reads complete mysql packages from the socket
*/
protected class MySqlChannel <: Resource {

    private static let BUFFER_SIZE = 1024

    private var buffer = Array<Byte>(BUFFER_SIZE, repeat: 0)

    private var socket: StreamingSocket

    private var lastRemaining: Array<Byte> = []

    protected init(socket: TcpSocket) {
        this.socket = socket
    }

    public override func close() {
        socket.close()
    }

    public override func isClosed(): Bool {
        return socket.isClosed()
    }

    protected func getSocket(): StreamingSocket {
        return socket
    }

    protected func setSocket(socket: StreamingSocket): Unit {
        this.socket = socket
    }

    /*
     * read a mysql package from socket
     */
    protected func read(): Array<Byte> {
        //上一次读取有数据剩余
        if (this.lastRemaining.size > 3) {
            //尝试从上一次剩余的数据读取一个完整的数据包
            var subPacketLength = littleEndianToUInt32(lastRemaining.slice(0, 3))
            var fullPacketLength = Int64(subPacketLength) + 4
            if (lastRemaining.size >= fullPacketLength) {
                var data = lastRemaining.slice(0, fullPacketLength)
                var remainingSize = lastRemaining.size - fullPacketLength
                lastRemaining = lastRemaining.slice(fullPacketLength, remainingSize)
                return data
            }
        }
        var store = ArrayList<Byte>()
        if (lastRemaining.size > 0) {
            store.appendAll(lastRemaining)
        }

        var len = socket.read(buffer)
        if(len == 0){
            throw IOException("Read bytes from socket failed")
        }

        store.appendAll(buffer.slice(0, len))
        var subPacketLength = littleEndianToUInt32(store.toArray().slice(0, 3))
        var fullPacketLength = Int64(subPacketLength) + 4
        if (store.size < fullPacketLength) {
            // 发生拆包的情况
            var len: Int64 = 0
            while (store.size < fullPacketLength) {
                len = socket.read(buffer)
                store.appendAll(buffer.slice(0, len))
            }
        }
        //可能发生粘包的情况
        //存储剩余数据
        var remainingSize = store.size - fullPacketLength
        lastRemaining = store.toArray().slice(fullPacketLength, remainingSize)
        return store.toArray().slice(0, fullPacketLength)
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