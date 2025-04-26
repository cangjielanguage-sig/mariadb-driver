/*
 * Copyright (c) 2024 Yesokim
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mysql.protocol

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
            case LongPassword => return 1 << 0
            case FoundRows => return 1 << 1
            case LongFlags => return 1 << 2
            case ConnectWithDB => return 1 << 3
            case NoSchema => return 1 << 4
            case Compress => return 1 << 5
            case ODBC => return 1 << 6
            case LocalFiles => return 1 << 7
            case IgnoreSpace => return 1 << 8
            case Protocol41 => return 1 << 9
            case Interactive => return 1 << 10
            case SSL => return 1 << 11
            case IgnoreSigpipe => return 1 << 12
            case Transactions => return 1 << 13
            case Reserved => return 1 << 14
            case Reserved2 => return 1 << 15
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