//
//  SessionModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 21.11.2024.
//

import Foundation

import Foundation

struct SessionResponse: Codable {
    let total: Int
    let sessions: [SessionModel]
}

struct SessionModel: Identifiable, Codable {
    let id = UUID() // Unique identifier for SwiftUI's `ForEach
    let session_id: Int
    let user: String
    let groupName: String?
    let image: String?
    let last_message: String
    let last_message_date: String
    
    enum CodingKeys: String, CodingKey {
        case session_id, user, groupName, image, last_message, last_message_date
    }
}
