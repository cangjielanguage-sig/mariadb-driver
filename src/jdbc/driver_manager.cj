/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
package cjmd.jdbc

import std.collection.ArrayList
import std.collection.concurrent.ConcurrentHashMap

public class DriverManager {

    private static let driversMap: ConcurrentHashMap<String, Driver> = ConcurrentHashMap<String, Driver>(3)

    public static func deregister(driverName: String): Unit {
        driversMap.remove(driverName)
    }

    public static func drivers(): Array<String> {
        var drivers = ArrayList<String>(driversMap.size)
        for((key,_) in driversMap){
            drivers.append(key)
        }
        return drivers.toArray()
    }

    public static func getDriver(driverName: String): Option<Driver> {
        return driversMap.get(driverName)
    }

    public static func register(driverName: String, driver: Driver): Unit {
        driversMap.put(driverName, driver)
    }

}