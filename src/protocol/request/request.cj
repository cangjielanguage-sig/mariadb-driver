/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol.request

import std.io.*
import mysql.util.*
import mysql.protocol.*

protected abstract class Request {

    private static let SINGLE_PACKAGE_MAX: Int64 = (1 << 24) - 1

    private let buffer: ByteBuffer = ByteBuffer()

    protected var number: UInt8

    protected init(number: UInt8) {
        this.number = number
    }

    protected func pack(data: Array<Byte>): Unit {
        buffer.write(data)
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