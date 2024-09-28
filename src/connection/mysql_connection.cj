/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 * @author Yesokim
 */
protected package cjmd.connection

import cjmd.protocol.*
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
import cjmd.result.*

protected class MySqlConnection <: Resource {

    private static let SHA256_REQUESET_KEY_CODE: Byte = 0x01

    private static let CACHING_SHA2_REQUEST_KEY_CODE: Byte = 0x02
    
    private let connectionMutex: ReentrantMutex = ReentrantMutex()

    private var channel: MySqlChannel

    private MySqlConnection(channel: MySqlChannel) {
        this.channel = channel
    }

    protected prop mutex: ReentrantMutex {
        get() {
            connectionMutex
        }
    }

    public override func close() {
        if (!channel.isClosed()) {
            channel.close()
        }
    }

    public override func isClosed(): Bool {
        return channel.isClosed()
    }

    /**
     * 将Query类型语句按可能返回的数据包类型分为一下三种
     * Command: 
     *     执行后只返回OkResponse或者ErrorResponse,同时只关注命令是否执行成功,
     *     不关注返回值,如果命令执行失败抛出ResponseErrorException
     * Query: 
     *     查询,关注查询的数据结果,如果执行成功返回TaularResult,如果命令执行失败抛出ResponseErrorException
     * Update: 
     *     更新,关注数据更新的结果,执行成功返回ChangeResult,如果命令执行失败抛出ResponseErrorException
     */


    /**
    * 向MySql服务器发送一条命令
    * @throws ResponseErrorException
    */
    protected func sendCommand(sql: String): Unit {
        synchronized(connectionMutex) {
            sendQuerySql(sql)
            readCommandResponse()
        }
    }

    /**
    * 向MySql发送一条查询语句
    * @return ResultSet
    * @throw ResponseErrorException
    */
    protected func sendQuery(sql: String): ResultSet {
        synchronized(connectionMutex) {
            sendQuerySql(sql)
            return readQueryResponse()
        }
    }

    /**
    * 向MySql发送一条更新语句
    * @return ChangeResult
    * @throw ResponseErrorException
    */
    protected func sendUpdate(sql: String): ChangeResult {
        synchronized(connectionMutex) {
            sendQuerySql(sql)
            return readUpdateResponse()
        }
    }

    /**
    * 向MySql发送一条预编译语句
    * @return PrepareResult
    * @throw ResponseErrorException
    */
    protected func sendPrepare(sql: String): PrepareResult {
        synchronized(connectionMutex) {
            writeRequest(PrepareCommand.create(sql))
            return readPrepareResponse()
        }
    }

    /**
    * 执行查询预编译语句
    * @param prepare: PrepareResult 预编译语句结果
    * @param params: Array<Any> 语句参数
    * @result ResultSet 查询结果集
    * @throws ResponseErrorException
    */
    protected func executeQueryPrepare(prepare: PrepareResult, params: Array<Any>): ResultSet {
        synchronized(connectionMutex) {
            handleLongData(prepare.id, params)
            writeRequest(ExecuteCommand.default(prepare.id, prepare.parameterDefinition, params))
            return readExecutePrepareResponse()
        }
    }

    /**
    * 执行更新预编译语句
    * @param prepare: PrepareResult 预编译语句结果
    * @param params: Array<Any> 语句参数
    * @result ResultSet 更新结果
    * @throws ResponseErrorException
    */
    protected func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        synchronized(connectionMutex) {
            handleLongData(prepare.id, params)
            writeRequest(ExecuteCommand.default(prepare.id, prepare.parameterDefinition, params))
            return readUpdateResponse()
        }
    }

    /**
    * 释放预编译语句
    * @param id: UInt32 预编译语句id
    */
    protected func closePrepare(id: UInt32): Unit {
        synchronized(connectionMutex) {
            writeRequest(CloseCommand(id))
        }
    }

    private func sendQuerySql(sql: String) {
        writeRequest(QueryCommand.create(sql))
    }

    private func handleLongData(statementId: UInt32, params: Array<Any>){
        for(i in 0..params.size){
            var param = params[i]
            match (param) {
                case v:InputStream => writeRequest(SendLongDataCommand(statementId, UInt16(i), inputStreamToArray(v)))
                case v:Array<Byte> => writeRequest(SendLongDataCommand(statementId,  UInt16(i), v))
                case v:?InputStream => if(!v.isNone()){writeRequest(SendLongDataCommand(statementId, UInt16(i), inputStreamToArray(v.getOrThrow())))}
                case v:?Array<Byte> => if(!v.isNone()){writeRequest(SendLongDataCommand(statementId, UInt16(i), v.getOrThrow()))}
                case _ => nothingTodo(0)
            }
        }
    }


    /*
     * 读取预执行语句响应
     */
    private func readPrepareResponse(): PrepareResult {
        var array = channel.read()
        var stream = arrayToInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var prepareResponse = PrepareResposne(stream)
        var parameters = ArrayList<ColumnDefinition>(Int64(prepareResponse.numParams))
        if(prepareResponse.numParams > 0){
            for (_ in 0..prepareResponse.numParams) {
                parameters.append(ColumnDefinition(arrayToInputStream(channel.read())))
            }
            channel.read()
        }
        
        var columns = ArrayList<ColumnDefinition>(Int64(prepareResponse.numColumns))
        if(prepareResponse.numColumns > 0){
            for (_ in 0..prepareResponse.numColumns) {
            columns.append(ColumnDefinition(arrayToInputStream(channel.read())))
            }
            channel.read()
        }
        return PrepareResult(prepareResponse, parameters.toArray(), columns.toArray())
    }

    /*
    * 读取执行查询预执行语句响应
    */
    private func readExecutePrepareResponse(): ResultSet {
        var array = channel.read()
        var stream = arrayToInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var filedsCount = ColumnCount(stream)
        var fields = ArrayList<ColumnDefinition>()
        for (_ in 0..filedsCount.count) {
            var field = ColumnDefinition(arrayToInputStream(channel.read()))
            fields.append(field)
        }
        //丢弃Eof包
        channel.read()
        array = channel.read()
        var rowPackets = ArrayList<BinaryResult>()
        while (array[4] != ResponseCode.Eof.value() || array.size > 9) {
            var row = BinaryResult(arrayToInputStream(array), fields.toArray())
            rowPackets.append(row)
            array = channel.read()
        }
        return BinaryResultSet(fields.toArray(), rowPackets.toArray())
    }


    /*
     * 读取握手报文
     */
    private func readHandhake(): Handshake {
        return Handshake(arrayToInputStream(channel.read()))
    }

    /*
     * 读取一个mysql响应报文,可能是OkResponse、ErrorResponse、AbstructEof和AuthStateResponse 或者其子类
     */
    private func readResponse(): Response {
        var array = channel.read()
        var code = ResponseCode.get(array[4])
        match (code) {
            case ResponseCode.Ok =>
                return OkResponse(arrayToInputStream(array))
            case ResponseCode.Error =>
                return ErrorResponse(arrayToInputStream(array))
            case ResponseCode.Eof => return getEofResponse(array)
            case ResponseCode.AuthMoreData => return getAuthMoreData(array)
        }
    }

    private func getEofResponse(array: Array<Byte>): AbstractEOF {
        var stream = arrayToInputStream(array)
        if (array.size > 9) {
            return AuthSwitch(stream)
        } else {
            return EofResponse(stream)
        }
    }

    private func getAuthMoreData(array: Array<Byte>): AuthMoreData {
        var authCode = array[5]
        var stream = arrayToInputStream(array)
        if (array.size == 6 && (authCode == AuthState.FastAuthSuccess.value() || authCode == AuthState.PerformFullAuthentication.value())) {
            return AuthStatus(stream)
        } else {
            return PublicKeyResponse(stream)
        }
    }

    private func writeRequest(req: Request) {
        channel.write(req.toByteArray())
    }


    /*
    * 处理命令语句响应
    */
    private func readCommandResponse() {
        var response = readResponse()
        if (response is ErrorResponse) {
            var error = response as ErrorResponse
            throw ResponseErrorException(error.getOrThrow().message)
        }
    }

    /*
     * 处理查询语句的响应
     */
    private func readQueryResponse(): ResultSet {
        var array = channel.read()
        var stream = arrayToInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var columnCount = ColumnCount(stream)
        var fields = ArrayList<ColumnDefinition>()
        for (_ in 0..columnCount.count) {
            var field = ColumnDefinition(arrayToInputStream(channel.read()))
            fields.append(field)
        }
        //丢弃Eof包
        channel.read()
        array = channel.read()
        var rowPackets = ArrayList<TextResult>()
        while (array[4] != ResponseCode.Eof.value() || array.size > 9) {
            var row: TextResult
            row = TextResult(arrayToInputStream(array), Int64(columnCount.count))
            rowPackets.append(row)
            array = channel.read()
        }
        return TextResultSet(fields.toArray(), rowPackets.toArray())
    }

    /*
     * 处理更新语句的响应
     */
    private func readUpdateResponse(): ChangeResult {
        var array = channel.read()
        var stream = arrayToInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var ok = OkResponse(stream)
        return ChangeResult(ok.effectRows, ok.index)
    }


    /**
     * 创建一个完成认证的mysql连接
     * @params option: Map<String, String> 连接参数
     */
    protected static func createAuthedConnection(option: Map<String, String>): MySqlConnection {
        try {
            // 1. 建立TCP连接,设置参数
            var socket = connectToServer(option)

            // 2. 准备认证报文
            var connection = MySqlConnection(MySqlChannel(socket))
            var handshake = connection.readHandhake()
            var sslModel = option.get(Params.SSLMode).getOrDefault({=> "preferred"})
            var sslable = handshake.hasCapability(Capability.SSL)
            if (!sslable && sslModel != "disabled" && sslModel != "preferred") {
                throw ConnectFailedException("Can't Switch to SSL after handshake")
            }

            // 3. 建立安全连接
            var sslEnabled = sslable && sslModel != "disabled"
            var authReq = prepareAuthRequest(handshake, option, sslEnabled)
            if (sslEnabled) {
                connection.channel.write(authReq.setCapability(SSL).sslRequest())
                sslHandshake(connection, option)
                authReq.setNumber(authReq.number + 1)
            }
            
            // 4.发送认证报文
            connection.writeRequest(authReq)
            connection.channel.flush()

            // 5. 处理认证响应,可能是 ErrorResponse, OkResponse, PublicKey ,AuthStatePacket 和 AuthSwitch这几种数据包
            var originPassword = option.get(Params.Password).getOrThrow({=> ConnectFailedException("Required connection parameters: password")})

            match (connection.readResponse()) {
                case ok: OkResponse => return connection
                case error: ErrorResponse => throw ConnectFailedException(error.message)
                case key: PublicKeyResponse => 
                    var encryptedPwd = performFullAuthentication(key.publicKey, originPassword.toArray(), handshake.salt)
                    return sendPassword(connection, encryptedPwd, key.number)
                case authSwitch: AuthSwitch =>
                        match (authSwitch.pluginName) {
                            case "caching_sha2_password" =>
                                var encryptedPwd = cachingSha2Password(originPassword.toArray(), authSwitch.salt)
                                connection.writeRequest(SendPassword(authSwitch.number + 1, encryptedPwd))
                                var response = connection.readResponse()
                                return checkCachingSha2PasswordAuthStatus(connection, response, originPassword, authSwitch.salt, sslEnabled)
                            case "sha256_password" => 
                                if(sslEnabled){
                                    return sendPassword(connection, toNullTerminated(originPassword), authSwitch.number)
                                }else{
                                    var publicKey: String
                                    var lastPacketNumber: UInt8
                                    (publicKey, lastPacketNumber) = requestPublicKey(connection, SHA256_REQUESET_KEY_CODE,authSwitch.number)
                                    var encryptedPwd = performFullAuthentication(publicKey, originPassword.toArray(), authSwitch.salt)
                                    return sendPassword(connection, encryptedPwd, lastPacketNumber)
                                }
                            case "mysql_native_password" =>
                                var encryptedPwd = mysqlNativePassword(originPassword.toArray(), authSwitch.salt)
                                return sendPassword(connection, encryptedPwd, authSwitch.number);
                            case _ => throw ConnectFailedException("Unsupported auth plugin")
                        }
                case authStatus: AuthStatus => 
                    return checkCachingSha2PasswordAuthStatus(connection, authStatus, originPassword, handshake.salt, sslEnabled)
                case _ => throw ConnectFailedException("connect to mysql failed")
            }
        } catch (e: SocketException | SocketTimeoutException) {
            throw ConnectFailedException(e.message)
        }
        throw ConnectFailedException("connect to mysql failed")
    }

    private static func connectToServer(option: Map<String, String>): TcpSocket {
        var host = option.get(Params.Host).getOrThrow({=> IllegalArgumentException("Required connection parameters: host")})
        var port = option.get(Params.Port).getOrThrow({=> IllegalArgumentException("Required connection parameters: port")})
        var connectionTimeout = option.get(Params.ConnectionTimeout)
        var socket = TcpSocket(host, UInt16.parse(port))
        match (connectionTimeout) {
            case None => socket.connect()
            case Some(v) => 
                try {
                    var timeout = Int64.parse(v)
                    socket.connect(timeout: Duration.millisecond * timeout)
                } catch (e: IllegalArgumentException) {
                    throw IllegalArgumentException("parse connection timeout failed")
                }
        }
        return socket
    }

    private static func prepareAuthRequest(handshake: Handshake, option: Map<String, String>, sslEnabled: Bool): HandshakeResponse {
        var username = option.get(Params.Username).getOrThrow({=> IllegalArgumentException("Required connection parameters: username")})
        var originPassword = option.get(Params.Password).getOrThrow({=> IllegalArgumentException("Required connection parameters: password")})
        var database = option.get(Params.Database).getOrDefault({=> ""})
        var authReq = HandshakeResponse.getDefault(handshake.number + 1)
        var encryptedPassword: Array<Byte>
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
        authReq.setUsername(username).setPassword(encryptedPassword).setClientAuthPlugin(handshake.authPlugin)
        if (database != "") {
            authReq.setCapability(ConnectWithDB).setDatabase(database)
        }
        return authReq
    }

    private static func sslHandshake(connection: MySqlConnection, option: Map<String, String>) {
        var config = TlsClientConfig()
        var sslMode = option.get(Params.SSLMode).getOrDefault({=> "preferred"})
        if (sslMode == "preferred" || sslMode == "required") {
            config.verifyMode = CertificateVerifyMode.TrustAll
        } else if (sslMode == "verify_ca") {
            var sslCA = option.get(Params.SSLCA)
            if (sslCA.isNone()) {
                throw ConnectFailedException("ssl.mode=verify_ca must set ssl.ca")
            }
            var certificates = X509Certificate.decodeFromPem(String.fromUtf8(File.readFrom(sslCA.getOrThrow())))
            config.verifyMode = CertificateVerifyMode.CustomCA(certificates)
        }
        config.clientCertificate = getClientCertificate(option)
        config.domain = option.get(Params.SSLSni)
        config.cipherSuitesV1_2 = option.get(Params.Tls12Ciphersuites).getOrDefault({=> ""}).split(":",removeEmpty: true)
        config.cipherSuitesV1_3 = option.get(Params.Tls13Ciphersuites).getOrDefault({=> ""}).split(":",removeEmpty: true)
        //(config.minVersion, config.maxVersion) = getMinAndMaxTlsVersion(option.get(Params.TlsVersion))
        var lastSession: ?TlsSession = None
        try {
            var tls: TlsSocket = TlsSocket.client(connection.channel.getSocket(), session: lastSession, clientConfig: config)
            tls.handshake()
            connection.channel.setSocket(tls)
        } catch (e: TlsException) {
            throw ConnectFailedException(e.message)
        }
    }

    private static func sendPassword(connection: MySqlConnection, password: Array<Byte>, lastPacketNumber: UInt8): MySqlConnection {
        connection.writeRequest(SendPassword(lastPacketNumber + 1, password))
        var response = connection.readResponse()
        match (response) {
            case r: OkResponse =>
                return connection
            case r: ErrorResponse => throw ConnectFailedException(r.message)
            case _ => throw ConnectFailedException("Out expect connection response")
        }
    }

    private static func checkCachingSha2PasswordAuthStatus(connection: MySqlConnection, response: Response, originPassword: String, salt: Array<Byte>, sslEnabled: Bool): MySqlConnection{
        var authState = (response as AuthStatus).getOrThrow()
        if (authState.state == AuthState.PerformFullAuthentication) {
            if (sslEnabled) {
                return sendPassword(connection, toNullTerminated(originPassword), authState.number)    
            } else {
                var publicKey: String
                var lastPacketNumber: UInt8
                (publicKey, lastPacketNumber) = requestPublicKey(connection, CACHING_SHA2_REQUEST_KEY_CODE,authState.number)
                var encryptedPwd = performFullAuthentication(publicKey, originPassword.toArray(), salt)
                return sendPassword(connection, encryptedPwd, lastPacketNumber)
            }
        } else if (authState.state == AuthState.FastAuthSuccess) {
            var response = connection.readResponse()
            match (response) {
                case r: OkResponse => return connection
                case r: ErrorResponse => throw ConnectFailedException(r.message)
                case _ => throw ConnectFailedException("Out expect Response")
            }
        }
        throw ConnectFailedException("connect to mysql failed")
    }

    private static func requestPublicKey(connection: MySqlConnection, requestKeyCode: Byte, lastPacketNumber: UInt8): (String, 
        UInt8) {
        var requestkey = RequestPublicKey(lastPacketNumber + 1, requestKeyCode)
        connection.writeRequest(requestkey)
        var response = connection.readResponse();
        if (response is ErrorResponse) {
            var error = (response as ErrorResponse).getOrThrow()
            throw ConnectFailedException(error.message)
        }
        var publicKey = (response as PublicKeyResponse).getOrThrow().publicKey
        return (publicKey, response.number)
    }

    private static func toNullTerminated(val: String): Array<Byte> {
        var list = ArrayList<Byte>()
        list.appendAll(val.toArray())
        list.append(0)
        return list.toArray()
    }

    // private static func getMinAndMaxTlsVersion(val: ?String): (TlsVersion, TlsVersion) {
    //     if (val.isNone()) {
    //         return (V1_2, V1_3)
    //     } else {
    //         var values = val.getOrThrow().split(",", removeEmpty: true)
    //         values.sort()
    //         var versions = ArrayList<TlsVersion>()
    //         var tls12used = false
    //         var tls13used = false
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
                        var certificates = X509Certificate.decodeFromPem(String.fromUtf8(File.readFrom(publicKeyPath)))
                        var privateKey: PrivateKey = match (certificates[0].publicKeyAlgorithm) {
                            case PublicKeyAlgorithm.RSA => RSAPrivateKey.decodeFromPem(privateKeyPath, password: option.get(Params.SSLKeyPassword))
                            case PublicKeyAlgorithm.ECDSA => ECDSAPrivateKey.decodeFromPem(privateKeyPath, password: option.get(Params.SSLKeyPassword))
                            case _ => throw ConnectFailedException("Unsupported protected key algorithm")
                        }
                        return (certificates, privateKey)
                }
            }
    }
}
