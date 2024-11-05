/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.cdbc

import std.database.sql.DriverManager
import std.database.sql.Driver
import std.database.sql.Datasource
import std.database.sql.PooledDatasource
import std.convert.Parsable
import std.collection.ArrayList
import encoding.url.URL
import encoding.url.UrlSyntaxException
import mysqlclient4cj.connection.Params

public class MySqlDriver <: Driver {

    private let _name: String = "CangjieMySqlDriver"

    private let _version: String = "1.0.0"

    private let _preferredPooling: Bool = true

    private static let INSTALCE = MySqlDriver()

    private MySqlDriver() {
    }

    public static prop instance: Driver {
        get() {
            INSTALCE
        }
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
            pooledDatasource.setOption(Params.Host, host)
            pooledDatasource.setOption(Params.Port, port)
            for ((k, v) in opts) {
                setPooledDataSourceParam(pooledDatasource, k, v)
                pooledDatasource.setOption(k, v)
            }
            var username = parsedUrl.userInfo.username()
            if(username.size > 0){
                pooledDatasource.setOption(Params.Username, username)
            }
            var password = parsedUrl.userInfo.password()
            if(!password.isNone() && password.getOrThrow().size > 0){
                pooledDatasource.setOption(Params.Password, password.getOrThrow())
            }

            return pooledDatasource
        } catch (e: UrlSyntaxException) {
            throw IllegalArgumentException(e.message)
        }
    }

    private func setPooledDataSourceParam(pooledDatasource: PooledDatasource, k: String, v: String) {
        if (k == Params.PoolConnectionTimout) {
            try {
                var connnectionTimeout = Int64.parse(v)
                pooledDatasource.connectionTimeout = Duration.second * connnectionTimeout
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolConnectionTimout failed: ${v}")
            }
        }
        if (k == Params.PoolIdleTimout) {
            try {
                var idleTimeout = Int64.parse(v)
                pooledDatasource.idleTimeout = Duration.minute * idleTimeout
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolIdleTimout failed: ${v}")
            }
        }
        if (k == Params.PoolKeepaliveTime) {
            try {
                var keepaliveTime = Int64.parse(v)
                pooledDatasource.keepaliveTime = Duration.minute * keepaliveTime
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolKeepaliveTime failed: ${v}")
            }
        }
        if (k == Params.PoolMaxIdleSize) {
            try {
                var maxIdleSize = Int32.parse(v)
                pooledDatasource.maxIdleSize = maxIdleSize
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxIdleSize failed: ${v}")
            }
        }
        if (k == Params.PoolMaxLifeTime) {
            try {
                var maxLifeTime = Int64.parse(v)
                pooledDatasource.maxLifeTime = Duration.minute * maxLifeTime
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxLifeTime failed: ${v}")
            }
        }
        if (k == Params.PoolMaxSize) {
            try {
                var maxSize = Int32.parse(v)
                pooledDatasource.maxSize = maxSize
            } catch (e: IllegalArgumentException) {
                throw IllegalArgumentException("Parse PoolMaxSize failed: ${v}")
            }
        }
    }
}
