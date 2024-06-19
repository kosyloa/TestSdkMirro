//
//  SystemProperty.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation

public class SystemProperty {

    static func test() throws {
        try NativeProperty.test()
    }

    public static func setProperty(_ key: String, _ value: String) throws {
        try NativeProperty.setProperty(key, value)
    }

    public static func getProperty(_ key: String) -> String? {
        return NativeProperty.getProperty(key)
    }
}
