/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.protocol

/*
* Capabilities Flags
* referenced document: https://dev.mysql.com/doc/dev/mysql-server/latest/group__group__cs__capabilities__flags.html
*/
protected enum Capability {
    
    | LongPassword
    | FoundRows
    | LongFlags
    | ConnectWithDB
    | NoSchema
    | Compress
    | ODBC
    | LocalFiles
    | IgnoreSpace
    | Protocol41
    | Interactive
    | SSL
    | IgnoreSigpipe
    | Transactions
    | Reserved
    | Reserved2
    | MultiStatements
    | MultiResults
    | PsMultiResults
    | PluginAuth
    | ConnectAttrs
    | PluginAuthLenencClientData
    | CanHandleExpiredPasswords
    | SessionTrack
    | DeprecateEOF
    | OptionalResultSetMetadata
    | ZSTDCompressionAlgorithm
    | QueryAttributes
    | MultiFactorAuthentication
    | CapabilityExtension
    | SSLVerifyServerCert
    | RememberOptions

    internal func value(): UInt32 {
        match (this) {
            case LongPassword => return 1
            case FoundRows => return 2
            case LongFlags => return 4
            case ConnectWithDB => return 8
            case NoSchema => return 16
            case Compress => return 32
            case ODBC => return 64
            case LocalFiles => return 128
            case IgnoreSpace => return 256
            case Protocol41 => return 512
            case Interactive => return 1024
            case SSL => return 2048
            case IgnoreSigpipe => return 4096
            case Transactions => return 8192
            case Reserved => return 16384
            case Reserved2 => return 32768
            case MultiStatements => return 1 << 16
            case MultiResults => return 1 << 17
            case PsMultiResults => return 1 << 18
            case PluginAuth => return 1 << 19
            case ConnectAttrs => return 1 << 20
            case PluginAuthLenencClientData => return 1 << 21
            case CanHandleExpiredPasswords => return 1 << 22
            case SessionTrack => return 1 << 23
            case DeprecateEOF => return 1 << 24
            case OptionalResultSetMetadata => return 1 << 25
            case ZSTDCompressionAlgorithm => return 1 << 26
            case QueryAttributes => return 1 << 27
            case MultiFactorAuthentication => return 1 << 28
            case CapabilityExtension => return 1 << 29
            case SSLVerifyServerCert => return 1 << 30
            case RememberOptions => return 1 << 31
        }
    }
}