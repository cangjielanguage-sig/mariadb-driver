/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.impl

import std.database.sql.*
import std.convert.*
import encoding.url.*
import std.log.*
import std.console.*
import std.collection.*
import cjmd.connection.*
import std.time.*

public class MySqlDriver <: Driver {

    private let _name: String = "CangjieMySqlDriver"

    private let _version: String = "1.0.0"

    private let _preferredPooling: Bool = true

    private static let INSTALCE = MySqlDriver()

    private MySqlDriver() {
    }

    public static func getInstance(): Driver {
        return INSTALCE
    }

    public override prop name: String {
        get() {
            return _name
        }
    }

    public override prop version: String {
        get() {
            return _version
        }
    }

    public override prop preferredPooling: Bool {
        get() {
            return _preferredPooling
        }
    }

    /*通过 connectionString 和选项打开数据源*/
    //url example: mysql://localhost:3306
    public override func open(url: String, opts: Array<(String, String)>): Datasource {
        if (url.size == 0) {
            throw IllegalArgumentException("empty url")
        }
        try {
            var parsedUrl = URL.parse(url)
            var scheme = parsedUrl.scheme
            if (scheme != "mysql") {
                throw IllegalArgumentException("Bad connection url")
            }
            var host = parsedUrl.hostName
            if (host.size == 0) {
                throw IllegalArgumentException("Bad connection url")
            }
            var port = parsedUrl.port
            if(port == "") {
                port = "3306"
            }
            var dataSource = DatasourceImpl()
            var pooledDatasource = PooledDatasource(dataSource)
            pooledDatasource.setOption(ConnectionOption.Host, host)
            pooledDatasource.setOption(ConnectionOption.Port, port)
            for ((k, v) in opts) {
                setPooledDataSourceParam(pooledDatasource, k, v)
                pooledDatasource.setOption(k, v)
            }
            return pooledDatasource
        } catch (e: UrlSyntaxException) {
            throw IllegalArgumentException(e.message)
        }
    }

    private func setPooledDataSourceParam(pooledDatasource: PooledDatasource, k: String, v: String) {
        if (k == ConnectionOption.PoolConnectionTimout) {
            try {
                var connnectionTimeout = Int64.parse(v)
                pooledDatasource.connectionTimeout = Duration.second * connnectionTimeout
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolConnectionTimout failed: ${v}")
            }
        }
        if (k == ConnectionOption.PoolIdleTimout) {
            try {
                var idleTimeout = Int64.parse(v)
                pooledDatasource.idleTimeout = Duration.minute * idleTimeout
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolIdleTimout failed: ${v}")
            }
        }
        if (k == ConnectionOption.PoolKeepaliveTime) {
            try {
                var keepaliveTime = Int64.parse(v)
                pooledDatasource.keepaliveTime = Duration.minute * keepaliveTime
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolKeepaliveTime failed: ${v}")
            }
        }
        if (k == ConnectionOption.PoolMaxIdleSize) {
            try {
                var maxIdleSize = Int32.parse(v)
                pooledDatasource.maxIdleSize = maxIdleSize
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxIdleSize failed: ${v}")
            }
        }
        if (k == ConnectionOption.PoolMaxLifeTime) {
            try {
                var maxLifeTime = Int64.parse(v)
                pooledDatasource.maxLifeTime = Duration.minute * maxLifeTime
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxLifeTime failed: ${v}")
            }
        }
        if (k == ConnectionOption.PoolMaxSize) {
            try {
                var maxSize = Int32.parse(v)
                pooledDatasource.maxSize = maxSize
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxSize failed: ${v}")
            }
        }
    }
}
