/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.cdbc

public import cjmd.connection.ConnectionOption
import std.database.sql.DriverManager

let _ = DriverManager.register("mysql", MySqlDriver.instance)