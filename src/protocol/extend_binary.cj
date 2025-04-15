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
        if(buffer.size < 1 || buffer.size > 2) {
            throw IllegalArgumentException("Buffer size must between 1 and 2")
        }
        if(buffer.size < 2) {
            let temp = Array<Byte>(2, repeat: 0)
            buffer.copyTo(temp, 0, 0, buffer.size)
            return UInt16.readLittleEndian(temp)
        } else {
            return UInt16.readLittleEndian(buffer)
        }
    }
}

extend UInt32 <: LittleEndian<UInt32> {

    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(4, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): UInt32 {
        if(buffer.size < 1 || buffer.size > 4) {
            throw IllegalArgumentException("Buffer size must between 1 and 4")
        }
        if(buffer.size < 4) {
            let temp = Array<Byte>(4, repeat: 0)
            buffer.copyTo(temp, 0, 0, buffer.size)
            return UInt32.readLittleEndian(temp)
        } else {
            return UInt32.readLittleEndian(buffer)
        }
    }
}

extend UInt64 <: LittleEndian<UInt64> {

    public func toLittleEndian(): Array<Byte> {
        let buffer = Array<Byte>(8, repeat: 0)
        this.writeLittleEndian(buffer)
        return buffer
    }

    public static func fromLittleEndian(buffer: Array<Byte>): UInt64 {
        if(buffer.size < 1 || buffer.size > 8) {
            throw IllegalArgumentException("Buffer size must between 1 and 8")
        }
        if(buffer.size < 8) {
            let temp = Array<Byte>(8, repeat: 0)
            buffer.copyTo(temp, 0, 0, buffer.size)
            return UInt64.readLittleEndian(temp)
        } else {
            return UInt64.readLittleEndian(buffer)
        }
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