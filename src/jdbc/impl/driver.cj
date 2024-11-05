/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc.impl

import encoding.url.URL
import encoding.url.UrlSyntaxException
import mysqlclient4cj.jdbc.Driver
import mysqlclient4cj.jdbc.Datasource
import mysqlclient4cj.connection.Params


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
            datasource.setOption(Params.Host, host)
            datasource.setOption(Params.Port, port)
            for ((k, v) in opts) {
                datasource.setOption(k, v)
            }
            return datasource
        } catch (e: UrlSyntaxException) {
            throw IllegalArgumentException(e.message)
        }
    }
}
