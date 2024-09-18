/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

public interface Datasource <: Resource {

    func setOption(key: String, value: String): Unit

    func connect(): Connection

}