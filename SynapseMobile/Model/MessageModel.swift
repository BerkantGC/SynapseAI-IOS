//
//  MessageModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation

struct MessageResponse: Codable {
    let total: Int
    let messages: [MessageModel]
}

struct MessageModel: Identifiable, Codable {
    var id: Int
    var message: String
    var session_id: Int
    var sent_at: String
    var sender: String
    var me: Bool
    
    enum CodingKeys: CodingKey {
        case id
        case message
        case session_id
        case sent_at
        case sender
        case me
    }
}
