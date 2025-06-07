//
//  TimeHelper.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation

extension Date {
    
    static func isTokenValid(expiresAt: Int) -> Bool {
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        return currentTimestamp < expiresAt / 1000
    }
    
    static func convertDateStringToHourMinute(_ dateString: String) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = formatter.date(from: dateString) else {
            return nil
        }
        
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func stringToDate(_ dateString: String, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }
}
