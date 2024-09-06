/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.connection

import std.socket.*
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
import cjmd.packet.*
import cjmd.result.*


public class MySqlConnection <: Resource {

    private static let SHA256_REQUESET_KEY_CODE: Byte = 0x01

    private static let CACHING_SHA2_REQUEST_KEY_CODE: Byte = 0x02

    private static let BUFFER_SIZE = 1024

    private var _socket: StreamingSocket

    private var _lastRemaining: Array<Byte> = Array<Byte>()

    private let _connectionMutex: ReentrantMutex = ReentrantMutex()

    private MySqlConnection(socket: TcpSocket) {
        _socket = socket
    }

    private func setTlsSocket(tlsSocket: TlsSocket) {
        _socket = tlsSocket
    }

    public prop mutex: ReentrantMutex {
        get() {
            _connectionMutex
        }
    }

    /**
     * 将sql语句按可能返回的数据包类型分为一下三种
     * Command: 
     *     执行后只返回OkResponse或者ErrorResponse,同时只关注命令是否执行成功,
     *     不关注返回值,如果命令执行失败抛出ResponseErrorException
     * Query: 
     *     查询,关注查询的数据结果,如果执行成功返回TaularResult,如果命令执行失败抛出ResponseErrorException
     * Update: 
     *     更新,关注数据更新的结果,执行成功返回ChangeResult,如果命令执行失败抛出ResponseErrorException
     */
    public func sendCommand(sql: String) {
        synchronized(_connectionMutex) {
            sendQuerySql(sql)
            readIfErrorResponseThrow()
        }
    }

    public func sendQuery(sql: String): TabularResult {
        synchronized(_connectionMutex) {
            sendQuerySql(sql)
            return readQueryResponse()
        }
    }

    public func sendUpdate(sql: String): ChangeResult {
        synchronized(_connectionMutex) {
            sendQuerySql(sql)
            return readUpdateResponse()
        }
    }

    public func sendPrepare(sql: String): PrepareResult {
        synchronized(_connectionMutex) {
            writeRequest(PrepareCommand.create(sql))
            return readPrepareResponse()
        }
    }

    public func executeQueryPrepare(prepare: PrepareResult, params: Array<Any>): TabularResult {
        synchronized(_connectionMutex) {
            handleLongData(prepare.id, params)
            writeRequest(ExecuteCommand.default(prepare.id, prepare.parameterDefinition, params))
            return readExecutePrepareResponse()
        }
    }

    public func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        synchronized(_connectionMutex) {
            handleLongData(prepare.id, params)
            writeRequest(ExecuteCommand.default(prepare.id, prepare.parameterDefinition, params))
            return readUpdateResponse()
        }
    }

    public func closePrepare(prepare: PrepareResult): Unit {
        synchronized(_connectionMutex) {
            writeRequest(CloseCommand(prepare.id))
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

    private func inputStreamToArray(stream: InputStream): Array<Byte>{
        var buffer = Array<Byte>(1024, item: 0)
        var list = ArrayList<Byte>()
        var len = stream.read(buffer)
        while (len > 0) {
            list.appendAll(buffer)
            len = stream.read(buffer)
        }
        return list.toArray()
    }

    /*
     * 读取预执行语句响应
     */
    private func readPrepareResponse(): PrepareResult {
        var list = read()
        var stream = ByteArrayStream()
        stream.write(list)
        if (list[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var prepareResponse = PrepareResposne(stream)
        var parameters = ArrayList<ColumnDefinition>(Int64(prepareResponse.numParams))
        if(prepareResponse.numParams > 0){
            for (_ in 0..prepareResponse.numParams) {
                stream = ByteArrayStream()
                stream.write(read())
                parameters.append(ColumnDefinition(stream))
            }
            read()
        }
        
        var columns = ArrayList<ColumnDefinition>(Int64(prepareResponse.numColumns))
        if(prepareResponse.numColumns > 0){
            for (_ in 0..prepareResponse.numColumns) {
            stream = ByteArrayStream()
            stream.write(read())
            columns.append(ColumnDefinition(stream))
            }
            read()
        }
        return PrepareResult(prepareResponse, parameters.toArray(), columns.toArray())
    }

    /*
    * 读取执行查询预执行语句响应
    */
    private func readExecutePrepareResponse(): TabularResult {
        var list = read()
        var stream = ByteArrayStream()
        stream.write(list)
        if (list[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var filedsCount = ColumnCount(stream)
        var fields = ArrayList<ColumnDefinition>()
        for (_ in 0..filedsCount.count) {
            stream = ByteArrayStream()
            stream.write(read())
            var field = ColumnDefinition(stream)
            fields.append(field)
        }
        //丢弃Eof包
        read()
        list = read()
        var rowPackets = ArrayList<BinaryResultPacket>()
        while (list[4] != ResponseCode.Eof.value() || list.size > 9) {
            var stream = ByteArrayStream()
            stream.write(list)
            var row = BinaryResultPacket(stream, fields.toArray())
            rowPackets.append(row)
            list = read()
        }
        return BinaryResult(fields.toArray(), rowPackets.toArray())
    }

    /*
     * read a mysql package from socket
     */
    private func read(): Array<Byte> {
        //上一次读取有数据剩余
        if (this._lastRemaining.size > 3) {
            //尝试从上一次剩余的数据读取一个完整的数据包
            var subPacketLength = littleEndianToUInt32(_lastRemaining.slice(0, 3))
            var fullPacketLength = Int64(subPacketLength) + 4
            if (_lastRemaining.size >= fullPacketLength) {
                var data = _lastRemaining.slice(0, fullPacketLength)
                var remainingSize = _lastRemaining.size - fullPacketLength
                _lastRemaining = _lastRemaining.slice(fullPacketLength, remainingSize)
                return data
            }
        }
        var buffer = Array<Byte>(BUFFER_SIZE, item: 0)
        var store = ArrayList<Byte>()
        if (_lastRemaining.size > 0) {
            store.appendAll(_lastRemaining)
        }
        var len = _socket.read(buffer)
        store.appendAll(buffer.slice(0, len))
        var subPacketLength = littleEndianToUInt32(store.toArray().slice(0, 3))
        var fullPacketLength = Int64(subPacketLength) + 4
        if (store.size < fullPacketLength) {
            // 发生拆包的情况
            var len: Int64 = 0
            while (store.size < fullPacketLength) {
                len = _socket.read(buffer)
                store.appendAll(buffer.slice(0, len))
            }
        }
        //可能发生粘包的情况
        //存储下一个包的剩余数据
        var remainingSize = store.size - fullPacketLength
        _lastRemaining = store.toArray().slice(fullPacketLength, remainingSize)
        return store.toArray().slice(0, fullPacketLength)
    }

    /*
     * write a mysql package to socket
     */
    private func write(data: Array<Byte>) {
        _socket.write(data)
    }

    /*
     * flsuh buffer
     */
    private func flush() {
        _socket.flush()
    }

    /*
     * read a mysql handshake package
     */
    private func readHandhake(): Handshake {
        var stream = ByteArrayStream()
        stream.write(read())
        return Handshake(stream)
    }

    /*
     * 读取一个mysql响应报文,可能是OkResponse、ErrorResponse、AbstructEof和AuthStateResponse 或者其子类
     */
    private func readResponse(): Response {
        var list = read()
        var code = ResponseCode.get(list[4])
        match (code) {
            case ResponseCode.Ok =>
                var stream = ByteArrayStream()
                stream.write(list)
                return OkResponse(stream)
            case ResponseCode.Error =>
                var stream = ByteArrayStream()
                stream.write(list)
                return ErrorResponse(stream)
            case ResponseCode.Eof => return getEofResponse(list)
            case ResponseCode.AuthMoreData => return getAuthMoreData(list)
        }
    }

    private func getEofResponse(list: Array<Byte>): AbstractEOF {
        var stream = ByteArrayStream()
        stream.write(list)
        if (list.size > 9) {
            return AuthSwitch(stream)
        } else {
            return EofResponse(stream)
        }
    }

    private func getAuthMoreData(list: Array<Byte>): AuthMoreData {
        var authCode = list[5]
        var stream = ByteArrayStream()
        stream.write(list)
        if (list.size == 6 && (authCode == AuthState.FastAuthSuccess.value() || authCode ==
            AuthState.PerformFullAuthentication.value())) {
            return AuthStatus(stream)
        } else {
            return PublicKeyResponse(stream)
        }
    }

    private func writeRequest(req: Request) {
        write(req.toByteArray())
    }



    /*
    * 处理命令语句响应
    */
    private func readIfErrorResponseThrow() {
        var response = readResponse()
        if (response is ErrorResponse) {
            var error = response as ErrorResponse
            throw ResponseErrorException(error.getOrThrow().message)
        }
    }

    /*
     * 处理查询语句的响应
     */
    private func readQueryResponse(): TabularResult {
        var list = read()
        var stream = ByteArrayStream()
        stream.write(list)
        if (list[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var columnCount = ColumnCount(stream)
        var fields = ArrayList<ColumnDefinition>()
        for (_ in 0..columnCount.count) {
            stream = ByteArrayStream()
            stream.write(read())
            var field = ColumnDefinition(stream)
            fields.append(field)
        }
        //丢弃Eof包
        read()
        list = read()
        var rowPackets = ArrayList<TextResult>()
        while (list[4] != ResponseCode.Eof.value() || list.size > 9) {
            var row: TextResult
            var stream = ByteArrayStream()
            stream.write(list)
            row = TextResult(stream, Int64(columnCount.count))
            rowPackets.append(row)
            list = read()
        }
        return PlainResult(fields.toArray(), rowPackets.toArray())
    }

    /*
     * 处理更新语句的响应
     */
    private func readUpdateResponse(): ChangeResult {
        var list = read()
        var stream = ByteArrayStream()
        stream.write(list)
        if (list[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var ok = OkResponse(stream)
        return ChangeResult(ok.effectRows, ok.index)
    }


    public override func close() {
        if (!_socket.isClosed()) {
            _socket.close()
        }
    }

    public override func isClosed(): Bool {
        return _socket.isClosed()
    }

    /*
     * 创建一个完成认证的mysql连接
     * option: 连接参数
     */
    public static func createAuthedConnection(option: Map<String, String>): MySqlConnection {
        try {
            // 1. 建立TCP连接,设置参数
            var socket = connectToServer(option)

            // 2. 准备认证报文
            var connection = MySqlConnection(socket)
            var handshake = connection.readHandhake()
            var authReq = prepareAuthRequest(handshake.number + 1, handshake, option)

            var sslModel = option.get(ConnectionOption.SSLMode).getOrDefault({=> "preferred"})
            var sslable = handshake.hasCapability(Capability.SSL)

            if (!sslable && sslModel != "disabled" && sslModel != "preferred") {
                throw ConnectFailedException("Can't Switch to SSL after handshake")
            }

            // 3. 发送认证报文
            var sslEnabled = sslable && sslModel != "disabled"
            if (sslEnabled) {
                connection.write(authReq.setCapability(SSL).sslRequest())
                sslHandshake(connection, option)
                authReq.setNumber(authReq.number + 1)
            }
            connection.writeRequest(authReq)
            connection.flush()

            // 5. 处理认证响应,可能是 ErrorResponsePacket, AuthStatePacket 和 AuthSwitch这几种数据包
            var response = connection.readResponse()

            if (response is ErrorResponse) {
                var error = response as ErrorResponse
                throw ConnectFailedException(error.getOrThrow().message)
            }

            var originPassword = option.get(ConnectionOption.Password).getOrThrow(
                {=> ConnectFailedException("Required connection parameters: password")})
            if (response is AuthSwitch) {
                var authSwitch = (response as AuthSwitch).getOrThrow()
                if (sslEnabled) {
                    return sendPassword(connection, toNullTerminated(originPassword), authSwitch.number)
                } else {
                    var publicKey: String
                    var lastPacketNumber: UInt8
                    (publicKey, lastPacketNumber) = requestPublicKey(connection, SHA256_REQUESET_KEY_CODE,
                        authSwitch.number)
                    var encryptedPwd = performFullAuthentication(publicKey, originPassword.toArray(), authSwitch.salt)
                    return sendPassword(connection, encryptedPwd, lastPacketNumber)
                }
            }

            if (response is AuthStatus) {
                var authState = (response as AuthStatus).getOrThrow()
                if (authState.state == AuthState.PerformFullAuthentication) {
                    if (sslEnabled) {
                        return sendPassword(connection, toNullTerminated(originPassword), authState.number)
                    } else {
                        var publicKey: String
                        var lastPacketNumber: UInt8
                        (publicKey, lastPacketNumber) = requestPublicKey(connection, CACHING_SHA2_REQUEST_KEY_CODE,
                            authState.number)
                        var encryptedPwd = performFullAuthentication(publicKey, originPassword.toArray(), handshake.salt
                        )
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
            }
        } catch (e: SocketException | SocketTimeoutException) {
            throw ConnectFailedException(e.message)
        }
        throw ConnectFailedException("connect to mysql failed")
    }

    private static func connectToServer(option: Map<String, String>): TcpSocket {
        var host = option.get(ConnectionOption.Host).getOrThrow(
            {=> IllegalArgumentException("Required connection parameters: host")})
        var port = option.get(ConnectionOption.Port).getOrThrow(
            {=> IllegalArgumentException("Required connection parameters: port")})
        var connectionTimeout = option.get(ConnectionOption.ConnectionTimeOut)
        var socket = TcpSocket(host, UInt16.parse(port))
        if (!connectionTimeout.isNone()) {
            try {
                var timeout = Int64.parse(connectionTimeout.getOrThrow())
                socket.connect(timeout: Duration.millisecond * timeout)
            } catch (e: IllegalArgumentException) {
                throw ConnectFailedException("parse connection timeout failed")
            }
        } else {
            socket.connect()
        }

        return socket
    }

    private static func prepareAuthRequest(number: UInt8, handshake: Handshake, option: Map<String, String>): HandshakeResponse {
        var username = option.get(ConnectionOption.Username).getOrThrow(
            {=> IllegalArgumentException("Required connection parameters: username")})
        var originPassword = option.get(ConnectionOption.Password).getOrThrow(
            {=> IllegalArgumentException("Required connection parameters: password")})
        var database = option.get(ConnectionOption.Database).getOrDefault({=> ""})
        var authReq = HandshakeResponse.getDefault(number)
        var encryptedPassword: Array<Byte>
        match (handshake.authPlugin) {
            case "caching_sha2_password" =>
                encryptedPassword = cachingSha2Password(originPassword.toArray(),handshake.salt)
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
        var sslMode = option.get(ConnectionOption.SSLMode).getOrDefault({=> "preferred"})
        if (sslMode == "preferred") {
            config.verifyMode = CertificateVerifyMode.TrustAll
        } else if (sslMode == "verify_ca") {
            var sslCA = option.get(ConnectionOption.SSLCA)
            if (sslCA.isNone()) {
                throw ConnectFailedException("ssl.mode=verify_ca must set ssl.ca")
            }
            var certificates = X509Certificate.decodeFromPem(String.fromUtf8(File.readFrom(sslCA.getOrThrow())))
            config.verifyMode = CertificateVerifyMode.CustomCA(certificates)
        }
        config.clientCertificate = getClientCertificate(option)
        config.domain = option.get(ConnectionOption.SSLSni)
        config.cipherSuitesV1_2 = option.get(ConnectionOption.Tls12Ciphersuites)
                                        .getOrDefault({=> ""}).split(":",removeEmpty: true)
        config.cipherSuitesV1_3 = option.get(ConnectionOption.Tls13Ciphersuites)
                                        .getOrDefault({=> ""}).split(":",removeEmpty: true)
        (config.minVersion, config.maxVersion) = getMinAndMaxTlsVersion(option.get(ConnectionOption.TlsVersion))
        var lastSession: ?TlsSession = None
        try {
            var tls: TlsSocket = TlsSocket.client(connection._socket, session: lastSession, clientConfig: config)
            tls.handshake()
            connection.setTlsSocket(tls)
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

    private static func getMinAndMaxTlsVersion(val: ?String): (TlsVersion, TlsVersion) {
        if (val.isNone()) {
            return (V1_2, V1_3)
        } else {
            var values = val.getOrThrow().split(",", removeEmpty: true)
            values.sort()
            var versions = ArrayList<TlsVersion>()
            var tls12used = false
            var tls13used = false
            for (i in values) {
                match (i) {
                    case "TLSv1.2" => if (!tls12used) {
                        versions.append(V1_2)
                        tls12used = true
                    }
                    case "TLSv1.3" => if (!tls13used) {
                        versions.append(V1_3)
                        tls13used = true
                    }
                    case _ => throw ConnectFailedException("Unkonw TLS version: ${i}")
                }
            }
            return (versions[0], versions[versions.size - 1])
        }
    }

    private static func getClientCertificate(option: Map<String, String>): ?(Array<X509Certificate>, PrivateKey) {
        var clientCertificate = option.get(ConnectionOption.SSLCert)
        if (!clientCertificate.isNone()) {
            var key = option.get(ConnectionOption.SSLKey)
            if (key.isNone()) {
                throw ConnectFailedException("")
            }
            var certificates = X509Certificate.decodeFromPem(
                String.fromUtf8(File.readFrom(clientCertificate.getOrThrow())))
            var privateKey: PrivateKey = match (certificates[0].publicKeyAlgorithm) {
                case PublicKeyAlgorithm.RSA => RSAPrivateKey.decodeFromPem(key.getOrThrow(),
                    password: option.get(ConnectionOption.SSLKeyPassword))
                case PublicKeyAlgorithm.ECDSA => ECDSAPrivateKey.decodeFromPem(key.getOrThrow(),
                    password: option.get(ConnectionOption.SSLKeyPassword))
                case _ => throw ConnectFailedException("Unsupported public key algorithm")
            }
            return (certificates, privateKey)
        }
        return None
    }
}
