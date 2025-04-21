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
package mysql.xa

public class MySqlXid <: Hashable & Equatable<MySqlXid> {

    private var hash: Int = 0

    public let globalTransactionId: Array<Byte>

    public let branchQualifier: Array<Byte>

    public let formatId: UInt

    public init(globalTransactionId: Array<Byte>, branchQualifier!: Array<Byte> = [], formatId!: UInt = 1) {
        this.globalTransactionId = globalTransactionId
        this.branchQualifier = branchQualifier
        this.formatId = formatId
    }

    public override operator func == (right: MySqlXid): Bool {
        return this.globalTransactionId == right.globalTransactionId && 
               this.branchQualifier == right.branchQualifier && 
               this.formatId == right.formatId
    }

    public override func hashCode(): Int64 {
        if (this.hash == 0) {
            for (i in 1..this.globalTransactionId.size) {
                this.hash = 33 * this.hash + Int64(this.globalTransactionId[i])
            }
        }
        return this.hash
    }

}