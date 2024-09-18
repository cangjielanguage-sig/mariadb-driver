/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.connection

import crypto.digest.*
import crypto.keys.*
import std.convert.*
import std.io.*
import std.collection.*

/*
caching_sha2_password 插件
XOR(SHA256(password), SHA256(SHA256(SHA256(password)), nonce))
*/
internal func cachingSha2Password(password: Array<Byte>, salt: Array<Byte>): Array<Byte> {
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
    var x: Int64 = 0
    // 4. XOR(SHA256(password), SHA256(SHA256(SHA256(password)), nonce))
    while (x < scramble.size) {
        scramble[x] ^= digestStage1[x]
        x++
    }
    return scramble
}


internal func performFullAuthentication(pubPem: String,password: Array<Byte>, salt: Array<Byte>): Array<Byte>{
    var x: Int64 = 0
    var array = ArrayList<Byte>()
    array.appendAll(password)
    array.append(0x00)
    var pwd = array.toArray()
    while(x < pwd.size){
        pwd[x] ^= salt[x % salt.size]
        x++
    }
    var publicKey = RSAPublicKey.decodeFromPem(pubPem)
    var inStream = ByteArrayStream()
    inStream.write(pwd)
    var outStream = ByteArrayStream()
    publicKey.encrypt(inStream, outStream,padType: PadOption.OAEP(OAEPOption(SHA1(), SHA1(), label: "")))
    return outStream.bytes()
}

