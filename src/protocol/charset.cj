/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.protocol

public enum Charset {
    
    | Latin1SwedishCi
    | Utf8mb3GeneralCi
    | Binary

    public func value(): UInt16 {
        match (this) {
            case Latin1SwedishCi => return 8
            case Utf8mb3GeneralCi => return 33
            case Binary => return 63
        }
    }

    public static func of(value: UInt16): Charset {
        match (value) {
            case 8 => return Latin1SwedishCi
            case 33 => return Utf8mb3GeneralCi
            case 63 => return Binary
            case _=> throw UnsupportedException("Unsupported Charset: ${value}")
        }
    }
}