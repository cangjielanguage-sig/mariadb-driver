/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 * @author Yesokim
 */
protected package mysqlclient4cj.connection

import std.net.*
import std.collection.*
import std.convert.*
import std.io.*
import net.tls.*
import std.sync.*
import std.fs.*
import crypto.x509.*
import crypto.keys.*
import std.time.*
import std.sort.*
import mysqlclient4cj.result.*
import mysqlclient4cj.protocol.*

public class MySqlConnectionFactory {

    private static let SHA256_REQUESET_KEY_CODE: Byte = 0x01

    private static let CACHING_SHA2_REQUEST_KEY_CODE: Byte = 0x02

    /**
     * 创建一个完成认证的mysql连接
     * @params option: Map<String, String> 连接参数
     */
    protected static func createAuthedConnection(option: Map<String, String>): MySqlConnection {
        // 1. 建立TCP连接,设置参数
        let socket = connectToServer(option)

        // 2. 准备认证报文
        let connection = MySqlConnection(socket)
        let handshake = connection.readHandhake()
        let sslModel = option.get(Params.SSLMode).getOrDefault({=> "preferred"})
        let sslable = handshake.hasCapability(Capability.SSL)
        if (!sslable && sslModel != "disabled" && sslModel != "preferred") {
            throw ConnectFailedException("Can't Switch to SSL after handshake")
        }

        // 3. 建立安全连接
        let sslEnabled = sslable && sslModel != "disabled"
        let authReq = prepareAuthRequest(handshake, option, sslEnabled)
        if (sslEnabled) {
            connection.write(authReq.setCapability(SSL).sslRequest())
            sslHandshake(connection, option)
            authReq.setNumber(authReq.number + 1)
        }
            
        // 4.发送认证报文
        connection.writeRequest(authReq)
        connection.flush()

        // 5. 处理认证响应,可能是 ErrorResponse, OkResponse, PublicKey ,AuthStatePacket 和 AuthSwitch这几种数据包
        let originPassword = option.get(Params.Password).getOrThrow({=> ConnectFailedException("Required connection parameters: password")})

        match (connection.readResponse()) {
            case ok: OkResponse => return connection
            case error: ErrorResponse => throw ConnectFailedException(error.message)
            case key: PublicKeyResponse => 
                let encryptedPwd = performFullAuthentication(key.publicKey, originPassword.toArray(), handshake.salt)
                return sendPassword(connection, encryptedPwd, key.number)
            case authSwitch: AuthSwitch =>
                match (authSwitch.pluginName) {
                    case "caching_sha2_password" =>
                        let encryptedPwd = cachingSha2Password(originPassword.toArray(), authSwitch.salt)
                        connection.writeRequest(SendPassword(authSwitch.number + 1, encryptedPwd))
                        let response = connection.readResponse()
                        return checkCachingSha2PasswordAuthStatus(connection, response, originPassword, authSwitch.salt, sslEnabled)
                    case "sha256_password" => 
                        if(sslEnabled){
                            return sendPassword(connection, toNullTerminated(originPassword), authSwitch.number)
                        }else{
                            let (publicKey, lastPacketNumber) = requestPublicKey(connection, SHA256_REQUESET_KEY_CODE,authSwitch.number)
                            let encryptedPwd = performFullAuthentication(publicKey, originPassword.toArray(), authSwitch.salt)
                            return sendPassword(connection, encryptedPwd, lastPacketNumber)
                        }
                    case "mysql_native_password" =>
                        let encryptedPwd = mysqlNativePassword(originPassword.toArray(), authSwitch.salt)
                        return sendPassword(connection, encryptedPwd, authSwitch.number);
                    case _ => throw ConnectFailedException("Unsupported auth plugin")
                }
            case authStatus: AuthStatus => 
                return checkCachingSha2PasswordAuthStatus(connection, authStatus, originPassword, handshake.salt, sslEnabled)
            case _ => throw ConnectFailedException("connect to mysql failed")
        }
    }

    private static func connectToServer(option: Map<String, String>): TcpSocket {
        let host = option.get(Params.Host).getOrThrow({=> IllegalArgumentException("Required connection parameters: host")})
        let port = option.get(Params.Port).getOrThrow({=> IllegalArgumentException("Required connection parameters: port")})
        let connectionTimeout = option.get(Params.ConnectionTimeout)
        let socket = TcpSocket(host, UInt16.parse(port))
        match (connectionTimeout) {
            case None => 
                try {
                    socket.connect()
                }catch (e: SocketException | SocketTimeoutException) {
                    throw ConnectFailedException(e.message)
                }
            case Some(v) => 
                try {
                    let timeout = Int64.parse(v)
                    socket.connect(timeout: Duration.millisecond * timeout)
                } catch (e: IllegalArgumentException) {
                    throw IllegalArgumentException("parse connection timeout failed")
                } catch (e: SocketException | SocketTimeoutException) {
                    throw ConnectFailedException(e.message)
                }
        }
        return socket
    }

    private static func prepareAuthRequest(handshake: Handshake, option: Map<String, String>, sslEnabled: Bool): HandshakeResponse {
        let username = option.get(Params.Username).getOrThrow({=> IllegalArgumentException("Required connection parameters: username")})
        let originPassword = option.get(Params.Password).getOrThrow({=> IllegalArgumentException("Required connection parameters: password")})
        let database = option.get(Params.Database).getOrDefault({=> ""})
        let authReq = HandshakeResponse.getDefault(handshake.number + 1)
        let encryptedPassword: Array<Byte>
        match (handshake.authPlugin) {
            case "caching_sha2_password" =>
                encryptedPassword = cachingSha2Password(originPassword.toArray(),handshake.salt)
            case "sha256_password" => 
                if(sslEnabled){
                    encryptedPassword = toNullTerminated(originPassword)
                }else {
                    encryptedPassword =  [1]
                }
            case "mysql_native_password" =>
                encryptedPassword = mysqlNativePassword(originPassword.toArray(),handshake.salt)
            case _ => throw ConnectFailedException("Unknow authentication plugin")
        }
        authReq.setUsername(username).setAuthResponse(encryptedPassword).setClientAuthPlugin(handshake.authPlugin)
        if (database != "") {
            authReq.setCapability(ConnectWithDB).setDatabase(database)
        }
        return authReq
    }

    private static func sslHandshake(connection: MySqlConnection, option: Map<String, String>) {
        var config = TlsClientConfig()
        let sslMode = option.get(Params.SSLMode).getOrDefault({=> "preferred"})
        if (sslMode == "preferred" || sslMode == "required") {
            config.verifyMode = CertificateVerifyMode.TrustAll
        } else if (sslMode == "verify_ca") {
            let sslCA = option.get(Params.SSLCA)
            if (sslCA.isNone()) {
                throw ConnectFailedException("ssl.mode=verify_ca must set ssl.ca")
            }
            let certificates = X509Certificate.decodeFromPem(String.fromUtf8(File.readFrom(sslCA.getOrThrow())))
            config.verifyMode = CertificateVerifyMode.CustomCA(certificates)
        }
        config.clientCertificate = getClientCertificate(option)
        config.domain = option.get(Params.SSLSni)
        config.cipherSuitesV1_2 = option.get(Params.Tls12Ciphersuites).getOrDefault({=> ""}).split(":",removeEmpty: true)
        config.cipherSuitesV1_3 = option.get(Params.Tls13Ciphersuites).getOrDefault({=> ""}).split(":",removeEmpty: true)
        //(config.minVersion, config.maxVersion) = getMinAndMaxTlsVersion(option.get(Params.TlsVersion))
        let lastSession: ?TlsSession = None
        try {
            let tls: TlsSocket = TlsSocket.client(connection.socket, session: lastSession, clientConfig: config)
            tls.handshake()
            connection.socket = tls
        } catch (e: TlsException) {
            throw ConnectFailedException(e.message)
        }
    }

    private static func sendPassword(connection: MySqlConnection, password: Array<Byte>, lastPacketNumber: UInt8): MySqlConnection {
        connection.writeRequest(SendPassword(lastPacketNumber + 1, password))
        let response = connection.readResponse()
        match (response) {
            case r: OkResponse =>
                return connection
            case r: ErrorResponse => throw ConnectFailedException(r.message)
            case _ => throw ConnectFailedException("Out expect connection response")
        }
    }

    private static func checkCachingSha2PasswordAuthStatus(connection: MySqlConnection, response: Response, originPassword: String, salt: Array<Byte>, sslEnabled: Bool): MySqlConnection{
        let authState = (response as AuthStatus).getOrThrow()
        if (authState.state == AuthState.PerformFullAuthentication) {
            if (sslEnabled) {
                return sendPassword(connection, toNullTerminated(originPassword), authState.number)    
            } else {
                let (publicKey, lastPacketNumber) = requestPublicKey(connection, CACHING_SHA2_REQUEST_KEY_CODE,authState.number)
                let encryptedPwd = performFullAuthentication(publicKey, originPassword.toArray(), salt)
                return sendPassword(connection, encryptedPwd, lastPacketNumber)
            }
        } else if (authState.state == AuthState.FastAuthSuccess) {
            let response = connection.readResponse()
            match (response) {
                case r: OkResponse => return connection
                case r: ErrorResponse => throw ConnectFailedException(r.message)
                case _ => throw ConnectFailedException("Out expect Response")
            }
        }
        throw ConnectFailedException("connect to mysql failed")
    }

    private static func requestPublicKey(connection: MySqlConnection, requestKeyCode: Byte, lastPacketNumber: UInt8): (String, UInt8) {
        let requestkey = RequestPublicKey(lastPacketNumber + 1, requestKeyCode)
        connection.writeRequest(requestkey)
        let response = connection.readResponse();
        if (response is ErrorResponse) {
            let error = (response as ErrorResponse).getOrThrow()
            throw ConnectFailedException(error.message)
        }
        let publicKey = (response as PublicKeyResponse).getOrThrow().publicKey
        return (publicKey, response.number)
    }

    private static func toNullTerminated(val: String): Array<Byte> {
        let list = ArrayList<Byte>()
        list.appendAll(val.toArray())
        list.append(0)
        return list.toArray()
    }

    // private static func getMinAndMaxTlsVersion(val: ?String): (TlsVersion, TlsVersion) {
    //     if (val.isNone()) {
    //         return (V1_2, V1_3)
    //     } else {
    //         let values = val.getOrThrow().split(",", removeEmpty: true)
    //         values.sort()
    //         let versions = ArrayList<TlsVersion>()
    //         let tls12used = false
    //         let tls13used = false
    //         for (i in values) {
    //             match (i) {
    //                 case "TLSv1.2" => if (!tls12used) {
    //                     versions.append(V1_2)
    //                     tls12used = true
    //                 }
    //                 case "TLSv1.3" => if (!tls13used) {
    //                     versions.append(V1_3)
    //                     tls13used = true
    //                 }
    //                 case _ => throw ConnectFailedException("Unkonw TLS version: ${i}")
    //             }
    //         }
    //         return (versions[0], versions[versions.size - 1])
    //     }
    // }

    private static func getClientCertificate(option: Map<String, String>): ?(Array<X509Certificate>, PrivateKey) {
        match (option.get(Params.SSLCert)) {
            case None => None
            case Some(publicKeyPath) => 
                match (option.get(Params.SSLKey)) {
                    case None => throw ConnectFailedException()
                    case Some(privateKeyPath) => 
                        let certificates = X509Certificate.decodeFromPem(String.fromUtf8(File.readFrom(publicKeyPath)))
                        let privateKey: PrivateKey = match (certificates[0].publicKeyAlgorithm) {
                            case PublicKeyAlgorithm.RSA => RSAPrivateKey.decodeFromPem(privateKeyPath, password: option.get(Params.SSLKeyPassword))
                            case PublicKeyAlgorithm.ECDSA => ECDSAPrivateKey.decodeFromPem(privateKeyPath, password: option.get(Params.SSLKeyPassword))
                            case _ => throw ConnectFailedException("Unsupported protected key algorithm")
                        }
                        return (certificates, privateKey)
                }
            }
    }

}