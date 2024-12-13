//
//  TimeHelper.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation

extension Date{
    func isTokenValid(expiresAt: Int) -> Bool {
        let currentDate = Int(Date().timeIntervalSince1970)
        
        return currentDate < expiresAt/1000
    }
    
    func convertDateToString(date: String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateObj = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: dateObj!)
    }
}
