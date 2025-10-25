/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
protected package mariadb.protocol

protected enum Charset {
    
    | Binary
    | Utf8mb3
    | Utf8mb4

    protected static func of(value: UInt16): Charset {
        match (value) {
            case 63 => Binary
            case 33 | 83 | 223 | 1057 | 1107 | 1216 | 1238  => Utf8mb3
            case 45 | 46 | 1069 | 1070 | 1248 | 1270 => Utf8mb4
            case range where range >= 192 && range <= 215 => Utf8mb3
            case range where range >= 224 && range <= 309 => Utf8mb4
            case range where range >= 576 && range <= 579 => Utf8mb3
            case range where range >= 608 && range <= 611 => Utf8mb4
            case _=> throw UnsupportedException("Unsupported Charset: ${value}")
        }
    }
    
}