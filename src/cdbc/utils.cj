/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.cdbc

import std.database.sql.*

protected func insertCount(sql: String): Int {
    let lower = sql.toAsciiLower()
    let index = lower.indexOf("values") ?? throw SqlException()
    let values = lower[index + "values".size..lower.size]
    var depth = 0
    var count = 0
    for(i in values.runes()) {
        if(i == r'(') {
            depth ++
            if(depth == 1) {
                count ++
            }
        }else if(i == r')') {
            depth --
        }
    }
    return count
}

func escapeString(value: String): String {
    let builder = StringBuilder()
    builder.append("'")
    for(i in value.toRuneArray()) {
        match (i) {
            case r'\n' => builder.append("\\n")
            case r'\r' => builder.append("\\r")
            case r'\\' => builder.append("\\\\")
            case r'\'' => builder.append("\'\'")
            case r'"' => builder.append("\"")
            case _ => builder.append(i)
            }
        }
        builder.append("'")
        return builder.toString()
}