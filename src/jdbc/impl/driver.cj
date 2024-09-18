/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc.impl

import encoding.url.*
import cjmd.connection.ConnectionOption
import cjmd.jdbc.*

public class MySqlDriver <: Driver {
 
    private static let _instance: Driver = MySqlDriver()

    public static prop instance: Driver {
        get() {
            _instance
        }
    }

    private init() {}

    public func open(url: String, opts: Array<(String, String)>): Datasource {
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
            var datasource = DatasourceImpl()
            datasource.setOption(ConnectionOption.Host, host)
            datasource.setOption(ConnectionOption.Port, port)
            for ((k, v) in opts) {
                datasource.setOption(k, v)
            }
            return datasource
        } catch (e: UrlSyntaxException) {
            throw IllegalArgumentException(e.message)
        }
    }
}
