/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package mysql.cdbc

import std.io.*
import std.time.*
import std.math.numeric.*
import std.database.sql.*
import mysql.util.*

public interface SqlParameter {

    func asParameter(): String

}

extend Bool <: SqlParameter {

    public func asParameter(): String {
        if (this) {
            return "1"
        }else {
            return "0"
        }
    }

}

extend Int8 <: SqlParameter {

    public func asParameter(): String {
        return this.toString()
    }

}

extend UInt8 <: SqlParameter {

    public func asParameter(): String {
        return this.toString()
    }

}

extend Int16 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend UInt16 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend Int32 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend UInt32 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend Int64 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend UInt64 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend Float16 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend Float32 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend Float64 <: SqlParameter {
    public func asParameter(): String {
        return this.toString()
    }
}

extend ByteBuffer <: SqlParameter {

    public func asParameter(): String {
        return toHexStringWithPrefix(this)
    }
    
}

extend Array<Byte> <: SqlParameter {

    public func asParameter(): String {
        return toHexStringWithPrefix(this)
    }

}

extend String <: SqlParameter {

    public func asParameter(): String {
        return escapeString(this)
    }

}

extend DateTime <: SqlParameter {

    public func asParameter(): String {
        return "'" + this.format(DB_DATE_TIME_FORMAT) + "'"
    }

}

extend BigInt <: SqlParameter {

    public func asParameter(): String {
        return "'" + this.toString() + "'"
    }

}

extend Decimal <: SqlParameter {

    public func asParameter(): String {
        return "'" + this.toString() + "'"
    }

}

public interface Parameter {
    
    func asParameter(): String

    func unbox(): Any

}

extend SqlBool <: Parameter {

    public func asParameter(): String {
        if (this.value) {
            return "1"
        }else {
            return "0"
        }
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlByte <: Parameter {

    public func asParameter(): String {
        return this.value.toString()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlSmallInt <: Parameter{
    
    public func asParameter(): String {
        return this.value.toString()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlInteger <: Parameter {

    public func asParameter(): String {
        return this.value.toString()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlBigInt <: Parameter {
    
    public func asParameter(): String {
        return this.value.toString()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlReal <: Parameter {

    public func asParameter(): String {
        return this.value.toString()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlDouble <: Parameter {
    
    public func asParameter(): String {
        return this.value.toString()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlDecimal <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.toString() +"'"
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlChar <: Parameter {

    public func asParameter(): String {
        return escapeString(this.value.toString())
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlVarchar <: Parameter{
    
    public func asParameter(): String {
        return escapeString(this.value.toString())
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlClob <: Parameter {
    
    public func asParameter(): String {
        return toHexStringWithPrefix(this.value)
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlBlob <: Parameter {
    
    public func asParameter(): String {
        return toHexStringWithPrefix(this.value)
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlDate <: Parameter {

    public func asParameter(): String {
        return "'" + this.value.format(DB_DATE_FORMAT) + "'"
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlTime <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.format(DB_TIME_FORMAT) + "'"
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlTimeTz <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.format(DB_TIME_FORMAT) + "'"
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlTimestamp <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.format(DB_DATE_TIME_FORMAT) + "'"
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlBinary <: Parameter {
    
    public func asParameter(): String {
        return toHexStringWithPrefix(this.value)
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlVarBinary <: Parameter {
    
    public func asParameter(): String {
        return toHexStringWithPrefix(this.value)
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlNullableBool <: Parameter {
    
    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => 
                if (s) {
                    return "1"
                }else {
                    return "0"
                }
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableByte <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableSmallInt <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableInteger <: Parameter {
    
    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableBigInt <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableReal <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableDouble <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableDecimal <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.toString() + "'"
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableChar <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => escapeString(s.toString())
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }
}

extend SqlNullableVarchar <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => escapeString(s.toString())
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableClob <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => toHexStringWithPrefix(s)
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }
    
}

extend SqlNullableBlob <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => toHexStringWithPrefix(s)
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableDate <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.format(DB_DATE_FORMAT) + "'"
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }
    
}

extend SqlNullableTime <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.format(DB_TIME_FORMAT) + "'"
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }
    
}

extend SqlNullableTimeTz <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.format(DB_TIME_FORMAT) + "'"
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableTimestamp <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.format(DB_DATE_TIME_FORMAT) + "'"
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}

extend SqlNullableBinary <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => toHexStringWithPrefix(s)
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }
}

extend SqlNullableVarBinary <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => toHexStringWithPrefix(s)
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }
}
