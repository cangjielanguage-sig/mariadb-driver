/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.protocol

protected enum Charset {
    
    | Latin1SwedishCi
    | Utf8mb3GeneralCi
    | Utf8mb4GeneralCi
    | Utf8mb4Bin
    | Binary
    | Utf8mb3Bin

    protected func value(): UInt16 {
        match (this) {
            case Latin1SwedishCi => 8
            case Utf8mb3GeneralCi => 33
            case Utf8mb4GeneralCi => 45
            case Utf8mb4Bin => 46
            case Binary => 63
            case Utf8mb3Bin => 83
        }
    }

    protected static func of(value: UInt16): Charset {
        match (value) {
            case 8 => Latin1SwedishCi
            case 33 => Utf8mb3GeneralCi
            case 45 => Utf8mb4GeneralCi
            case 46 => Utf8mb4Bin
            case 63 => Binary
            case 83 => Utf8mb3Bin
            case _=> throw UnsupportedException("Unsupported Charset: ${value}")
        }
    }
}