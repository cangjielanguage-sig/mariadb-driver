/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

import std.collection.ArrayList
import std.collection.concurrent.{ConcurrentMap,ConcurrentHashMap}

public class DriverManager {


    private static let driversMap: ConcurrentMap<String, Driver> = ConcurrentHashMap<String, Driver>(1)


    public static func deregister(driverName: String): Unit {
        driversMap.remove(driverName)
    }

    public static func drivers(): Array<String> {
        return []
    }

    public static func getDriver(driverName: String): Option<Driver> {
        return driversMap.get(driverName)
    }

    public static func register(driverName: String, driver: Driver): Unit {
        driversMap.put(driverName, driver)
    }


}