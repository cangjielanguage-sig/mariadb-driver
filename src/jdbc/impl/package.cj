/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc.impl

import cjmd.jdbc.DriverManager

let _ = DriverManager.register("mysql", MySqlDriver.instance)