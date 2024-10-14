/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl

import mysqlclient4cj.jdbc.DriverManager

let _ = DriverManager.register("mysql", MySqlDriver.instance)