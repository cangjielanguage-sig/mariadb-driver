/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.xa

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
            for (i in 0l..this.globalTransactionId.size) {
                this.hash = 33 * this.hash + Int64(this.globalTransactionId[i])
            }
        }
        return this.hash
    }

}