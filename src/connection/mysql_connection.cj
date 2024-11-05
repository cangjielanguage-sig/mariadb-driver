/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.connection

import std.io.InputStream
import std.sync.ReentrantMutex
import std.collection.ArrayList
import std.net.TcpSocket
import std.net.StreamingSocket
import mysqlclient4cj.result.ResultSet
import mysqlclient4cj.result.ChangeResult
import mysqlclient4cj.result.PrepareResult
import mysqlclient4cj.result.TextResultSet
import mysqlclient4cj.result.BinaryResultSet
import mysqlclient4cj.protocol.Request
import mysqlclient4cj.protocol.toArray
import mysqlclient4cj.protocol.Response
import mysqlclient4cj.protocol.Handshake
import mysqlclient4cj.protocol.AuthState
import mysqlclient4cj.protocol.OkResponse
import mysqlclient4cj.protocol.TextResult
import mysqlclient4cj.protocol.AuthStatus
import mysqlclient4cj.protocol.AuthSwitch
import mysqlclient4cj.protocol.nothingTodo
import mysqlclient4cj.protocol.ColumnCount
import mysqlclient4cj.protocol.AbstractEOF
import mysqlclient4cj.protocol.QuitCommand
import mysqlclient4cj.protocol.EofResponse
import mysqlclient4cj.protocol.ResponseCode
import mysqlclient4cj.protocol.QueryCommand
import mysqlclient4cj.protocol.BinaryResult
import mysqlclient4cj.protocol.FetchCommand
import mysqlclient4cj.protocol.AuthMoreData
import mysqlclient4cj.protocol.CloseCommand
import mysqlclient4cj.protocol.ErrorResponse
import mysqlclient4cj.protocol.toInputStream
import mysqlclient4cj.protocol.ExecuteCommand
import mysqlclient4cj.protocol.PrepareCommand
import mysqlclient4cj.protocol.PrepareResposne
import mysqlclient4cj.protocol.ColumnDefinition
import mysqlclient4cj.protocol.PublicKeyResponse
import mysqlclient4cj.protocol.HandshakeResponse
import mysqlclient4cj.protocol.SendLongDataCommand


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

    protected func read(): Array<Byte> {
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
            writeRequest(ExecuteCommand.default(prepare.id, prepare.paramDefinitions, params))
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
            writeRequest(ExecuteCommand.withReadOnly(prepare.id, prepare.paramDefinitions, params))
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
            writeRequest(ExecuteCommand.default(prepare.id, prepare.paramDefinitions, params))
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

    private func handleLongData(statementId: UInt32, params: Array<Any>){
        for(i in 0..params.size){
            var param = params[i]
            match (param) {
                case v:InputStream => writeRequest(SendLongDataCommand(statementId, UInt16(i), (toArray(v))))
                case v:Array<Byte> => writeRequest(SendLongDataCommand(statementId, UInt16(i), v))
                case v:?InputStream => if(!v.isNone()){writeRequest(SendLongDataCommand(statementId, UInt16(i), toArray(v.getOrThrow())))}
                case v:?Array<Byte> => if(!v.isNone()){writeRequest(SendLongDataCommand(statementId, UInt16(i), v.getOrThrow()))}
                case _ => nothingTodo(0)
            }
        }
    }


    /*
     * read response of prepare statemnt
     */
    private func readPrepareResponse(): PrepareResult {
        var array = read()
        var stream = toInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var prepareResponse = PrepareResposne(stream)
        var parameters = ArrayList<ColumnDefinition>(Int64(prepareResponse.numParams))
        if(prepareResponse.numParams > 0){
            for (_ in 0..prepareResponse.numParams) {
                parameters.append(ColumnDefinition(toInputStream(channel.read())))
            }
            read()
        }
        
        var columns = ArrayList<ColumnDefinition>(Int64(prepareResponse.numColumns))
        if(prepareResponse.numColumns > 0){
            for (_ in 0..prepareResponse.numColumns) {
            columns.append(ColumnDefinition(toInputStream(channel.read())))
            }
            read()
        }
        return PrepareResult(prepareResponse, parameters.toArray(), columns.toArray())
    }

    /*
    * read response of execute query prepare statemnt
    */
    private func readQueryPrepareResponse(): ResultSet {
        var array = read()
        var stream = toInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var filedsCount = ColumnCount(stream)
        var fields = ArrayList<ColumnDefinition>()
        for (_ in 0..filedsCount.count) {
            var field = ColumnDefinition(toInputStream(channel.read()))
            fields.append(field)
        }
        //丢弃Eof包
        read()
        array = read()
        var rows = ArrayList<Array<?Array<Byte>>>()
        while (array[4] != ResponseCode.Eof.value() || array.size > 9) {
            var row = BinaryResult(toInputStream(array), fields.toArray())
            rows.append(row.binaryData)
            array = read()
        }
        return BinaryResultSet(fields.toArray(), rows.toArray())
    }

    /*
    * read response of fetch result set
    */
    private func readFetchResponse(columnInfos: Array<ColumnDefinition>): ResultSet {
        var array = read()
        var stream = toInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var rows = ArrayList<Array<?Array<Byte>>>()
        while (array[4] != ResponseCode.Eof.value() || array.size > 9) {
            var row = BinaryResult(toInputStream(array), columnInfos)
            rows.append(row.binaryData)
            array = read()
        }
        return BinaryResultSet(columnInfos, rows.toArray())
    }

    /*
    * read response of execute query prepare with cursor
    */
    private func readQueryPrepareResponseWithCursor(prepareId: UInt32, fetchSize: UInt32): ResultSet {
        var array = read()
        var stream = toInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var filedsCount = ColumnCount(stream)
        var fields = ArrayList<ColumnDefinition>()
        for (_ in 0..filedsCount.count) {
            var field = ColumnDefinition(toInputStream(channel.read()))
            fields.append(field)
        }
        //drop eof package
        read()
        return CursorResultSet(prepareId, fields.toArray(), fetchSize ,this)
    }


    /*
     * read handshake package
     */
    internal func readHandhake(): Handshake {
        return Handshake(toInputStream(read()))
    }

    /*
     * read a response, maybe OkResponse,ErrorResponse,AbstructEof,AuthStateResponse or it's subclass
     */
    internal func readResponse(): Response {
        var array = read()
        var code = ResponseCode.get(array[4])
        match (code) {
            case ResponseCode.Ok =>
                return OkResponse(toInputStream(array))
            case ResponseCode.Error =>
                return ErrorResponse(toInputStream(array))
            case ResponseCode.Eof => return getEofResponse(array)
            case ResponseCode.AuthMoreData => return getAuthMoreData(array)
        }
    }

    private func getEofResponse(array: Array<Byte>): AbstractEOF {
        var stream = toInputStream(array)
        if (array.size > 9) {
            return AuthSwitch(stream)
        } else {
            return EofResponse(stream)
        }
    }

    private func getAuthMoreData(array: Array<Byte>): AuthMoreData {
        var authCode = array[5]
        var stream = toInputStream(array)
        if (array.size == 6 && (authCode == AuthState.FastAuthSuccess.value() || authCode == AuthState.PerformFullAuthentication.value())) {
            return AuthStatus(stream)
        } else {
            return PublicKeyResponse(stream)
        }
    }

    internal func writeRequest(req: Request): Unit {
        req.pack()
        write(req.toByteArray())
    }


    /*
    * handle response of execute command
    */
    private func readCommandResponse(): Unit {
        var response = readResponse()
        if (response is ErrorResponse) {
            var error = response as ErrorResponse
            throw ResponseErrorException(error.getOrThrow().message)
        }
    }

    /*
     * handler response of execute query
     */
    private func readQueryResponse(): ResultSet {
        var array = read()
        var stream = toInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var columnCount = ColumnCount(stream)
        var fields = ArrayList<ColumnDefinition>()
        for (_ in 0..columnCount.count) {
            var field = ColumnDefinition(toInputStream(channel.read()))
            fields.append(field)
        }
        //丢弃Eof包
        read()
        array = read()
        var rowPackets = ArrayList<TextResult>()
        while (array[4] != ResponseCode.Eof.value() || array.size > 9) {
            var row: TextResult
            row = TextResult(toInputStream(array), Int64(columnCount.count))
            rowPackets.append(row)
            array = channel.read()
        }
        return TextResultSet(fields.toArray(), rowPackets.toArray())
    }

    /*
     * handler response of execute update
     */
    private func readUpdateResponse(): ChangeResult {
        var array = read()
        var stream = toInputStream(array)
        if (array[4] == ResponseCode.Error.value()) {
            var error = ErrorResponse(stream)
            throw ResponseErrorException(error.message)
        }
        var ok = OkResponse(stream)
        return ChangeResult(ok.effectRows, ok.index)
    }

    private func checkResourceAvailability() {
        if (isClosed()) {
            throw Exception("The database Connection has been closed")
        }
    }

}
