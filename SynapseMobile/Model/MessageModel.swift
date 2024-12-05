//
//  MessageModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation

struct MessageResponse: Codable {
    var total: Int
    var messages: [MessageModel]
}

struct MessageModel: Identifiable, Codable {
    var id: Int
    var message: String
    var session_id: Int
    var sent_at: String
    var sender: String
    var seen_at: String?
    var me: Bool
    
    enum CodingKeys: CodingKey {
        case id
        case message
        case session_id
        case sent_at
        case seen_at
        case sender
        case me
    }
}
