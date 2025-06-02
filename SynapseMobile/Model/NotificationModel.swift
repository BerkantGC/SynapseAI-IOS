//
//  NotificationService.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 20.11.2024.
//

import Foundation
struct NotificationModel: Identifiable, Decodable {
    var id: Int
    var title: String
    var description: String?
    var url: String?
    var created_at: String
    var seen_at: String?
    var kind: String;
    var from: ProfileModel
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case description
        case url
        case created_at
        case seen_at
        case kind
        case from
    }
}

struct NotificationsReponse: Decodable {
    var notifications: [NotificationModel]?
    var notification: NotificationModel?
    var deleted_notification_id: Int?
    var total_count: Int?
}
