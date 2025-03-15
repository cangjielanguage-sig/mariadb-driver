/*
 * Copyright (c) Yesokim. 2024-2025. All rights reserved.
 */
package mysql.cdbc

import std.convert.*
import std.collection.*
import std.database.sql.*
import encoding.url.*
import mysql.connection.*
import std.database.sql.DriverManager

let _ = DriverManager.register("mysql", MySqlDriver())

public class MySqlDriver <: Driver {

    private let driverName: String = "MySqlDriver"

    private let driverVersion: String = "1.0.0"

    private let supportPooling: Bool = true

    protected MySqlDriver() {
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

    private func setPooledDataSourceParam(datasource: PooledDatasource, k: String, v: String): Unit {
        if (k == Params.PoolConnectionTimout) {
            let connnectionTimeout = Int64.tryParse(v) ?? throw IllegalArgumentException("Parse PoolConnectionTimout failed: ${v}")
            return datasource.connectionTimeout = Duration.second * connnectionTimeout
        }
        if (k == Params.PoolIdleTimout) {
            let idleTimeout = Int64.tryParse(v) ?? throw IllegalArgumentException("Parse PoolIdleTimout failed: ${v}")
            return datasource.idleTimeout = Duration.minute * idleTimeout
        }
        if (k == Params.PoolKeepaliveTime) {
            let keepaliveTime = Int64.tryParse(v) ?? throw IllegalArgumentException("Parse PoolKeepaliveTime failed: ${v}")
            return datasource.keepaliveTime = Duration.minute * keepaliveTime
        }
        if (k == Params.PoolMaxIdleSize) {
            let maxIdleSize = Int32.tryParse(v) ?? throw IllegalArgumentException("Parse PoolMaxIdleSize failed: ${v}")
            return datasource.maxIdleSize = maxIdleSize
        }
        if (k == Params.PoolMaxLifeTime) {
            let maxLifeTime = Int64.tryParse(v) ?? throw IllegalArgumentException("Parse PoolMaxLifeTime failed: ${v}")
            return datasource.maxLifeTime = Duration.minute * maxLifeTime
        }
        if (k == Params.PoolMaxSize) {
            let maxSize = Int32.tryParse(v) ?? throw IllegalArgumentException("Parse PoolMaxSize failed: ${v}")
            return datasource.maxSize = maxSize
        }
    }
}

