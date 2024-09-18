/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

public interface Driver {
    
    func open(connectionString: String, opts: Array<(String, String)>): Datasource

}