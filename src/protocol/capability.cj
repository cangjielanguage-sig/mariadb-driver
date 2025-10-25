/*
 * Copyright (C) 2024 Yesokim
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
protected package mariadb.protocol

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
            case LongPassword => 1 << 0
            case FoundRows => 1 << 1
            case LongFlags => 1 << 2
            case ConnectWithDB => 1 << 3
            case NoSchema => 1 << 4
            case Compress => 1 << 5
            case ODBC => 1 << 6
            case LocalFiles => 1 << 7
            case IgnoreSpace => 1 << 8
            case Protocol41 => 1 << 9
            case Interactive => 1 << 10
            case SSL => 1 << 11
            case IgnoreSigpipe => 1 << 12
            case Transactions => 1 << 13
            case Reserved => 1 << 14
            case Reserved2 => 1 << 15
            case MultiStatements => 1 << 16
            case MultiResults => 1 << 17
            case PsMultiResults => 1 << 18
            case PluginAuth => 1 << 19
            case ConnectAttrs => 1 << 20
            case PluginAuthLenencClientData => 1 << 21
            case CanHandleExpiredPasswords => 1 << 22
            case SessionTrack => 1 << 23
            case DeprecateEOF => 1 << 24
            case OptionalResultSetMetadata => 1 << 25
            case ZSTDCompressionAlgorithm => 1 << 26
            case QueryAttributes => 1 << 27
            case MultiFactorAuthentication => 1 << 28
            case CapabilityExtension => 1 << 29
            case SSLVerifyServerCert => 1 << 30
            case RememberOptions => 1 << 31
        }
    }

}

protected class DefaultCapability {

    protected static var default: UInt32 = 0

    protected static func set(capability: Capability) {
        default |= capability.value()
    }

    protected static func has(capability: Capability): Bool {
        return (default & capability.value()) != 0
    }

    static init() {
        set(LongPassword)
        set(LongFlags)
        set(LocalFiles)
        set(Protocol41)
        set(Interactive)
        set(Transactions)
        set(MultiStatements)
        set(MultiResults)
        set(PluginAuth)
        set(ConnectAttrs)
        set(PluginAuthLenencClientData)
        set(CanHandleExpiredPasswords)
        set(SessionTrack)
        set(RememberOptions)
        set(Reserved2)
    }

}