/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc.impl

public import cjmd.connection.ConnectionOption
import cjmd.jdbc.DriverManager

let _ = DriverManager.register("mysql", MySqlDriver.instance)