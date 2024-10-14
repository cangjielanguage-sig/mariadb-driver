/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package mysqlclient4cj.connection

protected class Params {
    
    /**
    * 连接数据库的用户名。
    */
    protected static const Username: String = "username"

    /**
    * 连接数据库的密码。
    */
    protected static const Password: String = "password"

    /**
    * 数据库服务器主机名或者 IP 地址。
    */
    protected static const Host: String = "host"

    /**
    * 数据库服务器端口
    */
    protected static const Port: String = "port"

    /**
    * 数据库名
    */
    protected static const Database: String = "database"

    /**
    * connect 操作的超时时间，单位 ms。
    */
    protected static const ConnectionTimeout = "connection_timeout"

    /**
    * 数据库字符集编码类型。当前仅支持UTF-8
    */
    protected static const Encoding: String = "encoding"

    /**
    * query 操作的超时时间，单位 ms。
    */
    protected static const QueryTimeout = "query_timeout"

    /**
    * update 操作的超时时间，单位 ms。
    */
    protected static const UpdateTimeout = "update_timeout"

    /**
    * 传输层加密模式。
    */
    protected static const SSLMode: String = "ssl.mode"

    /**
    * 证书颁发机构（ CA ）证书文件的路径名。
    */
    protected static const SSLCA: String = "ssl.ca"

    /**
    * 客户端 SSL 公钥证书文件的路径名。
    */
    protected static const SSLCert = "ssl.cert"                                                                                                 

    /**
    * 客户端 SSL 私钥文件的路径名。
    */
    protected static const SSLKey = "ssl.key"

    /**
    * 客户端 SSL 私钥文件的密码。
    */
    protected static const SSLKeyPassword = "ssl.key.password"

    /**
    * 客户端通过该标识在握手过程开始时试图连接到哪个主机名。
    */
    protected static const SSLSni = "ssl.sni"

    /**
    * 此选项指定客户端允许使用 TLSv1.2 及以下的加密连接使用哪些密码套件。
    * 值为冒号分隔的字符串，比如 "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:TLS_DHE_RSA_WITH_AES_128_CBC_SHA"。
    */
    protected static const Tls12Ciphersuites = "tls1.2.ciphersuites"

    /**
    * 此选项指定客户端允许使用 TLSv1.3 的加密连接使用哪些密码套件。 
    * 值为冒号分隔的字符串，比如 "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256"。
    */    
    protected static const Tls13Ciphersuites = "tls1.3.ciphersuites"

    /**
    * 支持的 TLS 版本号，值为逗号分隔的字符串，比如 "TLSv1.2,TLSv1.3"。
    */
    protected static const TlsVersion = "tls.version"

    /**
    * 从池中获取连接的超时时间。默认30s
    */
    protected static const PoolConnectionTimout = "pool.connection_timeout"

    /**
    * 允许连接在池中闲置的最长时间，超过这个时间的空闲连接可能会被回收。默认10m
    */
    protected static const PoolIdleTimout = "pool.idle_timeout"

    /**
    * 检查空闲连接健康状况的间隔时间，防止它被数据库或网络基础设施超时。默认1m
    */
    protected static const PoolKeepaliveTime = "pool.keepalive_time"

    /**
    * 最大空闲连接数量，超过这个数量的空闲连接会被关闭，负数或0表示无限制。默认0
    */
    protected static const PoolMaxIdleSize = "pool.max_idle_size"

    /**
    * 自连接创建以来的持续时间，在该持续时间之后，连接将自动关闭。默认30m
    */
    protected static const PoolMaxLifeTime = "pool.max_life_time"

    /**
    * 连接池最大连接数量，负数或0表示无限制。默认10
    */
    protected static const PoolMaxSize = "pool.max_size"

    /**
    * PrepareStatemet模式,
    * 可取值: 
    * client: 使用客户端模拟的PrepareStatemtn，默认值
    * server: 使用服务器提供的PrepareStatement(仅支持mysql服务器，TiDB、OceanBase的支持不完善)
    */
    protected static const PrepareMode ="prepare.mode"
}