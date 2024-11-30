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
        guard let stringValue = ProcessInfo.processInfo.environment[key],
              let value = T(stringValue)
        else {
            fatalError("Environment variable '\(key)' not found or not convertible to \(T.self)")
        }
        self.wrappedValue = value
    }
    
    init(_ key: String, _ defaultValue: T) {
        if let stringValue = ProcessInfo.processInfo.environment[key],
           let value = T(stringValue) {
            self.wrappedValue = value
        } else {
            self.wrappedValue = defaultValue
        }
    }
}
