/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.result

/*
* 值转换异常
*/
public class ValueConvertException <: Exception{
    init(){
       super()
    }

    ValueConvertException(message: String) {
        super(message)    
    }

    public func toString(): String{
        return message
    }
}