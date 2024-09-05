/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.connection

/*
* 服务器响应Error异常,表示执行命令后服务器响应Error
*/
public class ResponseErrorException <: Exception{

    init(){
       super()
    }

    internal ResponseErrorException(message: String) {
        super(message)    
    }

    public func toString(): String{
        return message
    }
}

/*
*  连接失败异常
*/
public class ConnectFailedException <: Exception{
    init(){
       super()
    }

    protected ConnectFailedException(message: String) {
        super(message)    
    }

    public func toString(): String{
        return message
    }
}