package mysql.cdbc

import std.database.sql.*
import mysql.protocol.*

public interface Parameter {
    
    func asParameter(): String

}

extend SqlBool <: Parameter {

    public func asParameter(): String {
        return "'" + this.value.toString() + "'"
    }

}

extend SqlByte <: Parameter {

    public func asParameter(): String {
        return this.value.toString()
    }

}

extend SqlSmallInt <: Parameter{
    
    public func asParameter(): String {
        return this.value.toString()
    }

}

extend SqlInteger <: Parameter {

    public func asParameter(): String {
        return this.value.toString()
    }

}

extend SqlBigInt <: Parameter {
    
    public func asParameter(): String {
        return this.value.toString()
    }

}

extend SqlReal <: Parameter {

    public func asParameter(): String {
        return this.value.toString()
    }

}

extend SqlDouble <: Parameter {
    
    public func asParameter(): String {
        return this.value.toString()
    }

}

extend SqlDecimal <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.toString() +"'"
    }

}

extend SqlChar <: Parameter {

    public func asParameter(): String {
        return escapeString(this.value.toString())
    }

}

extend SqlVarchar <: Parameter{
    
    public func asParameter(): String {
        return escapeString(this.value.toString())
    }

}

extend SqlClob <: Parameter {
    
    public func asParameter(): String {
        return toArray(this.value).toHexStringWithPrefix()
    }

}

extend SqlBlob <: Parameter {
    
    public func asParameter(): String {
        return toArray(this.value).toHexStringWithPrefix()
    }

}

extend SqlDate <: Parameter {

    public func asParameter(): String {
        return "'" + this.value.format(DB_DATE_FORMAT) + "'"
    }

}

extend SqlTime <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.format(DB_TIME_FORMAT) + "'"
    }

}

extend SqlTimeTz <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.format(DB_TIME_FORMAT) + "'"
    }

}

extend SqlTimestamp <: Parameter {
    
    public func asParameter(): String {
        return "'" + this.value.format(DB_DATE_TIME_FORMAT) + "'"
    }

}

extend SqlBinary <: Parameter {
    
    public func asParameter(): String {
        return this.value.toHexStringWithPrefix()
    }

}

extend SqlVarBinary <: Parameter {
    
    public func asParameter(): String {
        return this.value.toHexStringWithPrefix()
    }

}

extend SqlJson <: Parameter {
    
    public func asParameter(): String {
        return escapeString(this.value.toJsonString())
    }

}

extend SqlNullableBool <: Parameter {
    
    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.toString() + "'"
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
    
}

extend SqlNullableSmallInt <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
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

}

extend SqlNullableBigInt <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
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
    
}

extend SqlNullableDouble <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toString()
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

}

extend SqlNullableChar <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => escapeString(s.toString())
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

}

extend SqlNullableClob <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => toArray(s).toHexStringWithPrefix()
        }
    }
    
}

extend SqlNullableBlob <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => toArray(s).toHexStringWithPrefix()
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
    
}

extend SqlNullableTime <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.format(DB_TIME_FORMAT) + "'"
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
    
}

extend SqlNullableTimestamp <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => "'" + s.format(DB_DATE_TIME_FORMAT) + "'"
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
    
}

extend SqlNullableVarBinary <: Parameter {

    public func asParameter(): String {
        match (this.value) {
            case None => "NULL"
            case Some(s) => s.toHexStringWithPrefix()
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

}