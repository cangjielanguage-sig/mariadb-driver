/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.packet

/*
* 无效数据包异常类,表示数据包解析异常
*/
public class InvalidPacketException <: Exception {

    init(){
       super()
    }

    protected InvalidPacketException(message: String) {
        super(message)    
    }

    public func toString(): String{
        return message
    }  
}

public class ParameterConvertException <: Exception {

    init() {
        super()
    }

    protected ParameterConvertException(message: String) {
        super(message)
    }

    public func toString(): String{
        return message
    } 

}