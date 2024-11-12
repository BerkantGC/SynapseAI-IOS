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
}
