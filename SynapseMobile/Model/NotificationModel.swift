//
//  NotificationService.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 20.11.2024.
//

import Foundation
struct NotificationModel: Identifiable, Codable {
    var id: String
    var title: String
    var username: String
    var created_at: String?
    var seen_at: String?
}
