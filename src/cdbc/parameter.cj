/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
package mysql.cdbc

import std.io.*
import std.time.*
import std.math.numeric.*
import mysql.connection.*

public interface SqlParameter {

    func asParameter(): String

}

extend ?Any <: SqlParameter {

    public func asParameter(): String {
        if (this.isNone()) {
            return "NULL"
        } else {
            return ""
        }
    }

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

