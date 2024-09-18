/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.protocol

protected enum Charset {
    
    | Latin1SwedishCi
    | Utf8mb3GeneralCi
    | Binary

    protected func value(): UInt16 {
        match (this) {
            case Latin1SwedishCi => return 8
            case Utf8mb3GeneralCi => return 33
            case Binary => return 63
        }
    }

    protected static func of(value: UInt16): Charset {
        match (value) {
            case 8 => return Latin1SwedishCi
            case 33 => return Utf8mb3GeneralCi
            case 63 => return Binary
            case _=> throw UnsupportedException("Unsupported Charset: ${value}")
        }
    }
}