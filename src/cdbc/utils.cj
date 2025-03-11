/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.cdbc

import std.regex.*

protected func insertCount(sql: String): Int {
    let lower = sql.toAsciiLower()
    let matcher = Regex("\\((.*?)\\)")
    return matcher.findAll(lower.split("values")[1]).size
}

func escapeString(value: String): String {
    let builder = StringBuilder()
    builder.append("'")
    for(i in value.toRuneArray()) {
        match (i) {
            // case r'\u{0000}' => builder.append("\\0")
            // case r'\n' => builder.append("\\n")
            // case r'\r' => builder.append("\\r")
            // case r'\u{001a}' => builder.append("\\Z")
            case r'\'' => builder.append("\'\'")
            case r'\\' => builder.append("\\\\")
            case _ => builder.append(i)
            }
        }
        builder.append("'")
        return builder.toString()
}