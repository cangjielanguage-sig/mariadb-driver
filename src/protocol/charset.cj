/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mysql.protocol

/*
* MySQL character set support
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_character_set.html
*/
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