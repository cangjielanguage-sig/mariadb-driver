/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysql.cdbc

import std.convert.*
import encoding.url.*
import std.collection.*
import std.database.sql.*
import mysql.connection.Params

public class MySqlDriver <: Driver {

    private let driverName: String = "CangjieMySqlDriver"

    private let driverVersion: String = "1.0.0"

    private let supportPooling: Bool = true

    private static let DRIVER = MySqlDriver()

    private MySqlDriver() {
    }

    public static prop instance: Driver {
        get() {
            DRIVER
        }
    }

    public override prop name: String {
        get() {
            return driverName
        }
    }

    public override prop version: String {
        get() {
            return driverVersion
        }
    }

    public override prop preferredPooling: Bool {
        get() {
            return supportPooling
        }
    }

    public override func open(url: String, opts: Array<(String, String)>): Datasource {
        let parsed = URL.parse(url)
        if (parsed.scheme != "mysql") {
            throw IllegalArgumentException("Bad connection url")
        }
        let host = parsed.hostName
        let port = parsed.port
        let datasource = PooledDatasource(DatasourceImpl())
        if (host.size > 0) {
            datasource.setOption(Params.Host, host)
        }
        if (port.size > 0) {
            datasource.setOption(Params.Port, port)
        }
        for ((k, v) in opts) {
            setPooledDataSourceParam(datasource, k, v)
            datasource.setOption(k, v)
        }
        let username = parsed.userInfo.username()
        if (username.size > 0) {
            datasource.setOption(Params.Username, username)
        }
        let password = parsed.userInfo.password()
        if (let Some(v) <- password && v.size > 0) {
            datasource.setOption(Params.Password, v)
        }
        return datasource
    }

    private func setPooledDataSourceParam(datasource: PooledDatasource, k: String, v: String) {
        if (k == Params.PoolConnectionTimout) {
            try {
                let connnectionTimeout = Int64.parse(v)
                datasource.connectionTimeout = Duration.second * connnectionTimeout
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolConnectionTimout failed: ${v}")
            }
        }else if (k == Params.PoolIdleTimout) {
            try {
                var idleTimeout = Int64.parse(v)
                datasource.idleTimeout = Duration.minute * idleTimeout
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolIdleTimout failed: ${v}")
            }
        }else if (k == Params.PoolKeepaliveTime) {
            try {
                var keepaliveTime = Int64.parse(v)
                datasource.keepaliveTime = Duration.minute * keepaliveTime
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolKeepaliveTime failed: ${v}")
            }
        }else if (k == Params.PoolMaxIdleSize) {
            try {
                var maxIdleSize = Int32.parse(v)
                datasource.maxIdleSize = maxIdleSize
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxIdleSize failed: ${v}")
            }
        }else if (k == Params.PoolMaxLifeTime) {
            try {
                var maxLifeTime = Int64.parse(v)
                datasource.maxLifeTime = Duration.minute * maxLifeTime
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxLifeTime failed: ${v}")
            }
        }else if (k == Params.PoolMaxSize) {
            try {
                var maxSize = Int32.parse(v)
                datasource.maxSize = maxSize
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxSize failed: ${v}")
            }
        }
    }
}
