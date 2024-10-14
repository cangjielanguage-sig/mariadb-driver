/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package mysqlclient4cj.jdbc


import std.collection.Map

public interface Connection <: Resource{

    func getMetaData(): Map<String,String>

    func prepareStatement(sql: String): Statement

    func setAutoCommit(autoCommit: Bool): Unit

    func getAutoCommit(): Bool

    func setTransactionIsolation(level: IsolationLevel): Unit

    func getTransactionIsolation(): IsolationLevel

    func begin(): Unit

    func commit(): Unit

    func rollback(): Unit

    func setSavepoint(name: String): Unit

    func rollback(name: String): Unit

    func releaseSavepoint(name: String): Unit

    func setReadOnly(readOnly: Bool): Unit

    func isReadOnly(): Bool

    func setSchema(schema: String): Unit

    func getSchema(): String
}


