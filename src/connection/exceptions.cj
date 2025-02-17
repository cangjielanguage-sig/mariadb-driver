/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
protected package mysql.connection

/*
* 服务器响应Error异常,表示执行命令后服务器响应Error
*/
protected class ResponseErrorException <: Exception {

    init() {
       super()
    }

    internal ResponseErrorException(message: String) {
        super(message)    
    }

}

/*
*  连接失败异常
*/
protected class ConnectFailedException <: Exception {
    init() {
       super()
    }

    internal ConnectFailedException(message: String) {
        super(message)    
    }
}