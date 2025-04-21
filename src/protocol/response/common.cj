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
protected package mysql.protocol.response

import std.io.*
import mysql.protocol.*

/*
* MySQL Packet
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_packets.html
*/
protected open class CommonResponse {

    protected let length: UInt64

    protected let number: UInt8

    internal init(length: UInt64, number: UInt8) {
        this.length = length
        this.number = number
    }

}

