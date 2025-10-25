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
protected package mariadb.connection

import std.io.*
import stdx.crypto.keys.*
import stdx.crypto.digest.*

/*
caching_sha2_password 插件
XOR(SHA256(password), SHA256(SHA256(SHA256(password)), nonce))
*/
internal func cachingSha2Password(password: Array<Byte>, salt: Array<Byte>): Array<Byte> {
    if(password.size == 0){
        return []
    }
    var sha256= SHA256()
    // 1. SHA256(password)
    sha256.write(password)
    var digestStage1: Array<Byte> = sha256.finish()
    sha256.reset()
    // 2. SHA256(SHA256(password))
    sha256.write(digestStage1)
    var digestStage2: Array<Byte> = sha256.finish()
    sha256.reset()
    // 3. SHA256(SHA256(SHA256(password)), nonce)
    sha256.write(digestStage2)
    sha256.write(salt)
    var scramble: Array<Byte> = sha256.finish()
    sha256.reset()
    // 4. XOR(SHA256(password), SHA256(SHA256(SHA256(password)), nonce))
    for(i in 0..scramble.size){
        scramble[i] ^= digestStage1[i]
    }
    return scramble
}

internal func performFullAuthentication(pubPem: String, password: Array<Byte>, salt: Array<Byte>): Array<Byte> {
    if(password.size == 0){
        return []
    }
    var x: Int64 = 0
    while(x < password.size){
        password[x] ^= salt[x % salt.size]
        x++
    }
    var publicKey = RSAPublicKey.decodeFromPem(pubPem)
    var inStream = ByteBuffer()
    inStream.write(password)
    var outStream = ByteBuffer()
    publicKey.encrypt(inStream, outStream, padType: PadOption.OAEP(OAEPOption(SHA1(), SHA1(), label: "")))
    return outStream.bytes()
}

internal func mariadbNativePassword(password: Array<Byte>, salt: Array<Byte>): Array<Byte> {
    if(password.size == 0) {
        return []
    }
    var sha1 = SHA1()
    sha1.write(password)
    var stage1 = sha1.finish()
    sha1.reset()
    sha1.write(stage1)
    var stage2 = sha1.finish()
    sha1.reset()
    sha1.write(salt)
    sha1.write(stage2)
    var scramble = sha1.finish()
    sha1.reset()
    for(i in 0..scramble.size) {
        scramble[i] ^= stage1[i]
    }
    return scramble
}
