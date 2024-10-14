/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.protocol

/*
* 无效数据包异常类,表示数据包解析异常
*/
protected class InvalidPacketException <: Exception {

    init(){
       super()
    }

    protected init(message: String) {
        super(message)    
    }
}

protected class ParameterConvertException <: Exception {

    init() {
        super()
    }

    protected init(message: String) {
        super(message)
    }

}