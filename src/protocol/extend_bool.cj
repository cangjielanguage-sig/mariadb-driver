/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysql.protocol


protected interface ToInteger {

    func toInteger(): UInt8

}

extend Bool <: ToInteger {

    public func toInteger(): UInt8 {
        match (this) {
            case true => 1
            case false => 0
        }
    }

}