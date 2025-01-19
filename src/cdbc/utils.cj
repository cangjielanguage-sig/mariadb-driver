/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysql.cdbc

import std.regex.*

protected func insertCount(sql: String): Int {
    let lower = sql.toAsciiLower()
    let matcher = Matcher(Regex("\\((.*?)\\)"), lower.split("values")[1])
    return matcher.findAll().getOrThrow().size
}