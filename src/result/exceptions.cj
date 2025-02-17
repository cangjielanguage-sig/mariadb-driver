/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.result

/*
* 值转换异常
*/
protected class ValueConvertException <: Exception {
    init() {
       super()
    }

    init(message: String) {
        super(message)    
    }

}