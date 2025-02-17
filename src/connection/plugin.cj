/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.connection

import std.io.*
import crypto.keys.*
import crypto.digest.*

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
    //var x: Int64 = 0
    // 4. XOR(SHA256(password), SHA256(SHA256(SHA256(password)), nonce))
    // while (x < scramble.size) {
    //     scramble[x] ^= digestStage1[x]
    //     x++
    // }
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

internal func mysqlNativePassword(password: Array<Byte>, salt: Array<Byte>): Array<Byte> {
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
