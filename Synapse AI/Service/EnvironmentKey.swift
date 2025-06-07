//
//  EnvironmentKe.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 30.11.2024.
//

import Foundation

@propertyWrapper
struct EnvironmentKey<T: LosslessStringConvertible> {
    var wrappedValue: T

    init(_ key: String) {
        if let envValue = ProcessInfo.processInfo.environment[key],
           let value = T(envValue) {
            self.wrappedValue = value
            return
        }

        if let plistValue = Bundle.main.infoDictionary?[key] as? String,
           let value = T(plistValue) {
            self.wrappedValue = value
            return
        }

        fatalError("Environment variable or plist value '\(key)' not found or not convertible to \(T.self)")
    }

    init(_ key: String, _ defaultValue: T) {
        if let envValue = ProcessInfo.processInfo.environment[key],
           let value = T(envValue) {
            self.wrappedValue = value
            return
        }

        if let plistValue = Bundle.main.infoDictionary?[key] as? String,
           let value = T(plistValue) {
            self.wrappedValue = value
            return
        }

        self.wrappedValue = defaultValue
    }
}

