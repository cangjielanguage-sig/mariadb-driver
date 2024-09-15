/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd

public import cjmd.connection.ConnectionOption
import std.database.sql.DriverManager
import cjmd.impl.MySqlDriver

let _ = DriverManager.register("mysql", MySqlDriver.getInstance())