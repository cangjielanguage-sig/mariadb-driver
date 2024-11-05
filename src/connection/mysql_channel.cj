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
// protected class MySqlChannel <: Resource {

//     private static let BUFFER_SIZE = 8192

//     private let buffer = Array<Byte>(BUFFER_SIZE, repeat: 0)

//     private var lastRemaining: Array<Byte> = []

//     internal var socket: StreamingSocket

//     protected init(socket: TcpSocket) {
//         this.socket = socket
//     }

//     public override func close() {
//         socket.close()
//     }

//     public override func isClosed(): Bool {
//         return socket.isClosed()
//     }

//     /*
//      * read a mysql package from socket
//      */
//     protected func read(): Array<Byte> {
//         //上一次读取有数据剩余
//         var subLength = 0
//         var fullLength = 0
//         if (this.lastRemaining.size > 3) {
//             //尝试从上一次剩余的数据读取一个完整的数据包
//             subLength = Int64(UInt32.fromLittleEndian(lastRemaining.slice(0, 3)))
//             fullLength = Int64(subLength) + 4
//             if (lastRemaining.size >= fullLength) {
//                 let data = lastRemaining.slice(0, fullLength)
//                 let remainingSize = lastRemaining.size - fullLength
//                 lastRemaining = lastRemaining.slice(fullLength, remainingSize)
//                 return data
//             }
//         }
//         var store = ArrayList<Byte>()
//         if(subLength > 0) {
//             store = ArrayList<Byte>(fullLength)
//         }

//         if (lastRemaining.size > 0) {
//             store.appendAll(lastRemaining)
//         }

//         var len = socket.read(buffer)
//         if(len == 0){
//             throw IOException("Read bytes from socket failed")
//         }
//         store.appendAll(buffer.slice(0, len))
//         subLength = Int64(UInt32.fromLittleEndian(store[0..3].toArray()))
//         fullLength = Int64(subLength) + 4
//         if (store.size < fullLength) {
//             // 发生拆包的情况
//             var len: Int64 = 0
//             while (store.size < fullLength) {
//                 len = socket.read(buffer)
//                 store.appendAll(buffer.slice(0, len))
//             }
//         }
//         //可能发生粘包的情况
//         //存储剩余数据
//         var remainingSize = store.size - fullLength
//         lastRemaining = store.toArray().slice(fullLength, remainingSize)
//         return store[0..fullLength].toArray()
//     }

//     /*
//      * write a mysql package to socket
//      */
//     protected func write(data: Array<Byte>) {
//         socket.write(data)
//     }

//     /*
//      * flsuh buffer
//      */
//     protected func flush() {
//         socket.flush()
//     }


// }

// protected class MySqlChannel <: Resource {

//     private static let BUFFER_SIZE = 8192

//     private var buffer = Array<Byte>(BUFFER_SIZE, repeat: 0)

//     private var lastRemaining: Array<Byte> = []

//     internal var socket: StreamingSocket

//     protected init(socket: TcpSocket) {
//         this.socket = socket
//     }

//     public override func close() {
//         socket.close()
//     }

//     public override func isClosed(): Bool {
//         return socket.isClosed()
//     }

//     /*
//      * read a mysql package from socket
//      */
//     protected func read(): Array<Byte> {
//         //上一次读取有数据剩余
//         if (this.lastRemaining.size > 3) {
//             //尝试从上一次剩余的数据读取一个完整的数据包
//             var subPacketLength = UInt32.fromLittleEndian(lastRemaining.slice(0, 3))
//             var fullPacketLength = Int64(subPacketLength) + 4
//             if (lastRemaining.size >= fullPacketLength) {
//                 var data = lastRemaining.slice(0, fullPacketLength)
//                 var remainingSize = lastRemaining.size - fullPacketLength
//                 lastRemaining = lastRemaining.slice(fullPacketLength, remainingSize)
//                 return data
//             }
//         }
//         var store = ArrayList<Byte>()
//         if (lastRemaining.size > 0) {
//             store.appendAll(lastRemaining)
//         }

//         var len = socket.read(buffer)
//         if(len == 0){
//             throw IOException("Read bytes from socket failed")
//         }

//         store.appendAll(buffer.slice(0, len))
//         var subPacketLength = UInt32.fromLittleEndian(store[0..3].toArray())
//         var fullPacketLength = Int64(subPacketLength) + 4
//         if (store.size < fullPacketLength) {
//             // 发生拆包的情况
//             var len: Int64 = 0
//             while (store.size < fullPacketLength) {
//                 len = socket.read(buffer)
//                 store.appendAll(buffer.slice(0, len))
//             }
//         }
//         //可能发生粘包的情况
//         //存储剩余数据
//         var remainingSize = store.size - fullPacketLength
//         lastRemaining = store.toArray().slice(fullPacketLength, remainingSize)
//         return store[0..fullPacketLength].toArray()
//     }

//     /*
//      * write a mysql package to socket
//      */
//     protected func write(data: Array<Byte>) {
//         socket.write(data)
//     }

//     /*
//      * flsuh buffer
//      */
//     protected func flush() {
//         socket.flush()
//     }


// }