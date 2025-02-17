/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol

import std.binary.*

protected interface LittleEndian<T> {

    func toLittleEndian(): Array<Byte>

    static func fromLittleEndian(buffer: Array<Byte>): T

}

extend UInt8 <: LittleEndian<UInt8> {

    public func toLittleEndian(): Array<Byte> {
        return [this]
    }

    public static func fromLittleEndian(buffer: Array<Byte>): UInt8 {
        if (buffer.size != 1) {
            throw IllegalArgumentException("buffer size must equals 1 ")
        }
        return buffer[0]
    }
}

extend UInt16 <: LittleEndian<UInt16> {

    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(2, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): UInt16 {
        if (buffer.size < 1 || buffer.size > 2) {
            throw IllegalArgumentException("buffer size must between 1 and 2")
        }
        var result: UInt16 = 0x00
        for(i in 0..buffer.size) {
            result |= UInt16(buffer[i]) << 8 * i
        }
        return result
    }
}

extend UInt32 <: LittleEndian<UInt32> {

    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(4, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): UInt32 {
        if (buffer.size < 1 || buffer.size > 4) {
            throw IllegalArgumentException("buffer size must between 1 and 4")
        }
        var result: UInt32 = 0x00
        for(i in 0..buffer.size) {
            result |= UInt32(buffer[i]) << 8 * i
        }
        return result
    }
}

extend UInt64 <: LittleEndian<UInt64> {

    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(8, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): UInt64 {
        if (buffer.size < 1 || buffer.size > 8) {
            throw IllegalArgumentException("buffer size must between 1 and 8")
        }
        var result: UInt64 = 0x00
        for(i in 0..buffer.size) {
            result |= UInt64(buffer[i]) << 8 * i
        }
        return result
    }
}

extend Float16 <: LittleEndian<Float16> {
    
    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(2, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): Float16 {
        return readLittleEndian(buffer)
    }
}

extend Float32 <: LittleEndian<Float32> {
    
    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(4, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): Float32 {
        return readLittleEndian(buffer)
    }
}

extend Float64 <: LittleEndian<Float64> {
    
    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(8, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): Float64 {
        return readLittleEndian(buffer)
    }
}