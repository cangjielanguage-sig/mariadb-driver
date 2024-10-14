/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.DriverManager

let _ = DriverManager.register("mysql", MySqlDriver.instance)