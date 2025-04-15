package mysql.cdbc

import std.database.sql.*
import mysql.protocol.*

public interface Parameter {
    
    func asParameter(): String

    func unbox(): Any

}

extend SqlBool <: Parameter {

    public func asParameter(): String {
        return "'" + this.value.toString() + "'"
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
        return this.value.toHexStringWithPrefix()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlVarBinary <: Parameter {
    
    public func asParameter(): String {
        return this.value.toHexStringWithPrefix()
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlJson <: Parameter {
    
    public func asParameter(): String {
        return escapeString(this.value.toJsonString())
    }

    public func unbox(): Any {
        return this.value
    }

}

extend SqlNullableBool <: Parameter {
    
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

extend SqlNullableInteger <: Parameter{
    
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
            case Some(s) => s.toHexStringWithPrefix()
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
            case Some(s) => s.toHexStringWithPrefix()
        }
    }
    
    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }
}

extend SqlNullableJson <: Parameter{
    
    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => escapeString(s.toJsonString())
        }
    }

    public func unbox(): Any {
        match (this.value) {
            case None => return Option<Any>.None
            case Some(s) => return s
        }
    }

}