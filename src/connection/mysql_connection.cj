/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.connection

import std.io.*
import std.net.*
import std.sync.*
import std.collection.*
import mysql.result.*
import mysql.protocol.*
import mysql.protocol.request.*
import mysql.protocol.response.*

/**
* The mysql connection object facilitates the upper-layer driver to interact with the database
*/
protected class MySqlConnection <: Resource {
    
    private let connectionMutex: ReentrantMutex = ReentrantMutex()

    private var channel: MySqlChannel

    internal init(socket: TcpSocket) {
        this.channel = MySqlChannel(socket)
    }

    protected prop mutex: ReentrantMutex {
        get() {
            connectionMutex
        }
    }

    protected mut prop socket: StreamingSocket {
        get() {
            channel.socket
        }
        set(value) {
            channel.socket = value
        }
    }

    protected func read(): (UInt32, Array<Byte>) {
        return channel.read()
    }

    protected func write(data: Array<Byte>): Unit {
        return channel.write(data)
    }

    protected func flush(): Unit {
        return channel.flush()
    }

    public override func close() {
        synchronized(connectionMutex){
            checkResourceAvailability()
            writeRequest(QuitCommand())
            channel.close()
        }
    }

    public override func isClosed(): Bool {
        return channel.isClosed()
    }

    /**
    * send a command to mysql server, like BEGIN or COMMIT statemnt without returned value
    * @throws ResponseErrorException
    */
    protected func sendCommand(sql: String): Unit {
        synchronized(connectionMutex) {
            writeRequest(QueryCommand(sql))
            readCommandResponse()
        }
    }

    /**
    * send a query statment to mysql server
    * @return ResultSet
    * @throw ResponseErrorException
    */
    protected func sendQuery(sql: String): ResultSet {
        synchronized(connectionMutex) {
            writeRequest(QueryCommand(sql))
            return readQueryResponse()
        }
    }

    /**
    * send a update statemnt to mysql server
    * @return ChangeResult
    * @throw ResponseErrorException
    */
    protected func sendUpdate(sql: String): ChangeResult {
        synchronized(connectionMutex) {
            writeRequest(QueryCommand(sql))
            return readUpdateResponse()
        }
    }

    /**
    * send a prepare statement to mysql server
    * @return PrepareResult
    * @throw ResponseErrorException
    */
    protected func sendPrepare(sql: String): PrepareResult {
        synchronized(connectionMutex) {
            writeRequest(PrepareCommand(sql))
            return readPrepareResponse()
        }
    }

    /**
    * execute prepare statement of the query type, all result sets from the query will be returned
    * @param prepare: PrepareResult 
    * @param params: Array<Any> 
    * @result ResultSet 
    * @throws ResponseErrorException
    */
    protected func executeQueryPrepare(prepare: PrepareResult, params: Array<Any>): ResultSet {
        synchronized(connectionMutex) {
            handleLongData(prepare.id, params)
            writeRequest(ExecuteCommand.default(prepare.id, prepare.params, params))
            return readQueryPrepareResponse()
        }
    }

    /**
    * execute prepare statemnt of the query type, it's will using cursors to fetch result set
    * @param prepare: PrepareResult 
    * @param params: Array<Any> 
    * @result ResultSet 
    * @throws ResponseErrorException
    */
    protected func executeQueryPrepareWithCurosr(prepare: PrepareResult, params: Array<Any>, fetchSize: UInt32): ResultSet {
        synchronized(connectionMutex) {
            handleLongData(prepare.id, params)
            writeRequest(ExecuteCommand.withReadOnly(prepare.id, prepare.params, params))
            return readQueryPrepareResponseWithCursor(prepare.id, fetchSize)
        }
    }

    /**
    * execute prepare statemnt of the update type
    * @param prepare: PrepareResult
    * @param params: Array<Any>
    * @result ResultSet
    * @throws ResponseErrorException
    */
    protected func executeUpdatePrepare(prepare: PrepareResult, params: Array<Any>): ChangeResult {
        synchronized(connectionMutex) {
            handleLongData(prepare.id, params)
            writeRequest(ExecuteCommand.default(prepare.id, prepare.params, params))
            return readUpdateResponse()
        }
    }

    /*
    * fetch some result set from prepare statemnt
    * @param prepareId: UInt32
    * @param fetchSize: UInt32
    */
    protected func fetchRows(prepareId: UInt32, columnInfos: Array<ColumnDefinition>, fetchSize: UInt32): ResultSet {
        synchronized(connectionMutex) {
            writeRequest(FetchCommand(prepareId, fetchSize))
            try {
                return readFetchResponse(columnInfos)
            }catch (e: ResponseErrorException) {
                return BinaryResultSet(columnInfos, [])
            }
        }
    }


    /**
    * close prepare statement
    * @param id: UInt32 预编译语句id
    */
    protected func closePrepare(id: UInt32): Unit {
        synchronized(connectionMutex) {
            writeRequest(CloseCommand(id))
        }
    } 

    protected func createTransaction(): MySqlTransaction {
        return MySqlTransaction(this)
    }

    private func handleLongData(statementId: UInt32, params: Array<Any>){
        for (i in 0..params.size) {
            let param = params[i]
            match (param) {
                case v:InputStream => writeRequest(SendLongDataCommand(statementId, UInt16(i), (toArray(v))))
                case v:Array<Byte> => writeRequest(SendLongDataCommand(statementId, UInt16(i), v))
                case _ => nothing(0)
            }
        }
    }


    /*
     * read response of prepare statemnt
     */
    private func readPrepareResponse(): PrepareResult {
        let (length, payload) = read()
        checkError(length, payload)
        let prepareResponse = PrepareResposne(length, ByteBuffer(payload))
        let parameters = ArrayList<ColumnDefinition>(Int64(prepareResponse.numParams))
        if(prepareResponse.numParams > 0){
            for (_ in 0..prepareResponse.numParams) {
                let (length, payload) = read()
                parameters.add(ColumnDefinition(length, ByteBuffer(payload)))
            }
            read()
        }
        let columns = ArrayList<ColumnDefinition>(Int64(prepareResponse.numColumns))
        if(prepareResponse.numColumns > 0) {
            for (_ in 0..prepareResponse.numColumns) {
                let (length, payload) = read()
                columns.add(ColumnDefinition(length, ByteBuffer(payload)))
            }
            read()
        }
        return PrepareResult(prepareResponse, parameters.toArray(), columns.toArray())
    }

    /*
    * read response of execute query prepare statemnt
    */
    private func readQueryPrepareResponse(): ResultSet {
        var (length, payload) = read()
        checkError(length, payload)
        let filedsCount = ColumnCount(length, ByteBuffer(payload))
        let fields = ArrayList<ColumnDefinition>()
        for (_ in 0..filedsCount.count) {
            let (length, payload) = read()
            let field = ColumnDefinition(length, ByteBuffer(payload))
            fields.add(field)
        }
        //丢弃Eof包
        read()
        (length, payload) = read()
        let rows = ArrayList<Array<?Array<Byte>>>()
        while (payload[1] != ResponseCode.Eof.value() || payload.size > 6) {
            let row = BinaryResult(length, ByteBuffer(payload), fields.toArray())
            rows.add(row.binaryData)
            (length, payload) = read()
        }
        return BinaryResultSet(fields.toArray(), rows.toArray())
    }

    /*
    * read response of fetch result set
    */
    private func readFetchResponse(columnInfos: Array<ColumnDefinition>): ResultSet {
        var (length, payload) = read()
        checkError(length, payload)
        let rows = ArrayList<Array<?Array<Byte>>>()
        while (payload[1] != ResponseCode.Eof.value() || payload.size > 6) {
            let row = BinaryResult(length, ByteBuffer(payload), columnInfos)
            rows.add(row.binaryData)
            (length, payload) = read()
        }
        return BinaryResultSet(columnInfos, rows.toArray())
    }

    /*
    * read response of execute query prepare with cursor
    */
    private func readQueryPrepareResponseWithCursor(prepareId: UInt32, fetchSize: UInt32): ResultSet {
        let (length, payload) = read()
        checkError(length, payload) 
        let filedsCount = ColumnCount(length, ByteBuffer(payload))
        let fields = ArrayList<ColumnDefinition>()
        for (_ in 0..filedsCount.count) {
            let (length, payload) = read()
            let field = ColumnDefinition(length, ByteBuffer(payload))
            fields.add(field)
        }
        //drop eof package
        read()
        return CursorResultSet(prepareId, fields.toArray(), fetchSize ,this)
    }


    /*
     * read handshake package
     */
    internal func readHandhake(): Handshake {
        let (length, payload) = read()
        return Handshake(length, ByteBuffer(payload))
    }

    /*
     * read a response, maybe OkResponse,ErrorResponse,AbstructEof,AuthStateResponse or it's subclass
     */
    internal func readResponse(): Response {
        let (length, payload) = read()
        let code = ResponseCode.of(payload[1])
        match (code) {
            case ResponseCode.Ok =>
                return OkResponse(length, ByteBuffer(payload))
            case ResponseCode.Error =>
                return ErrorResponse(length, ByteBuffer(payload))
            case ResponseCode.Eof => return getEofResponse(length, payload)
            case ResponseCode.AuthMoreData => return getAuthMoreData(length, payload)
        }
    }

    private func getEofResponse(length: UInt32, payload: Array<Byte>): AbstractEOF {
        let stream = ByteBuffer(payload)
        if (payload.size > 9) {
            return AuthSwitch(length, stream)
        } else {
            return EofResponse(length, stream)
        }
    }

    private func getAuthMoreData(length: UInt32, payload: Array<Byte>): AuthMoreData {
        let authCode = payload[2]
        let stream = ByteBuffer(payload)
        if (payload.size == 3 && (authCode == AuthState.FastAuthSuccess.value() || authCode == AuthState.PerformFullAuthentication.value())) {
            return AuthStatus(length, stream)
        } else {
            return PublicKeyResponse(length, stream)
        }
    }

    internal func writeRequest(req: Request): Unit {
        write(req.toByteArray())
    }


    /*
    * handle response of execute command
    */
    private func readCommandResponse(): Unit {
        var response = readResponse()
        if (response is ErrorResponse) {
            let error = response as ErrorResponse
            throw ResponseErrorException(error.getOrThrow().message)
        }
    }

    /*
     * handler response of execute query
     */
    private func readQueryResponse(): ResultSet {
        var (length, payload) = read()
        checkError(length, payload)
        let columnCount = ColumnCount(length, ByteBuffer(payload))
        let fields = ArrayList<ColumnDefinition>()
        for (_ in 0..columnCount.count) {
            let (length, payload) = channel.read()
            let field = ColumnDefinition(length, ByteBuffer(payload))
            fields.add(field)
        }
        //丢弃Eof包
        read()
        (length, payload) = read()
        let rowPackets = ArrayList<TextResult>()
        while (payload[1] != ResponseCode.Eof.value() || payload.size > 6) {
            let row = TextResult(length, ByteBuffer(payload), Int64(columnCount.count))
            rowPackets.add(row)
            (length, payload) = channel.read()
        }
        return TextResultSet(fields.toArray(), rowPackets.toArray())
    }

    /*
     * handler response of execute update
     */
    private func readUpdateResponse(): ChangeResult {
        let(length, payload) = read()
        checkError(length, payload)
        let ok = OkResponse(length, ByteBuffer(payload))
        return ChangeResult(ok.effectRows, ok.index)
    }

    private func checkError(length: UInt32, payload: Array<Byte>) {
        if (payload[1] == ResponseCode.Error.value()) {
            let stream = ByteBuffer(payload)
            let error = ErrorResponse(length, stream)
            throw ResponseErrorException(error.message)
        }
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw Exception("The database Connection has been closed")
        }
    }

}
