/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql

import mysql.cdbc.MySqlDriver
import std.database.sql.DriverManager

let _ = DriverManager.register("mysql", MySqlDriver.instance)