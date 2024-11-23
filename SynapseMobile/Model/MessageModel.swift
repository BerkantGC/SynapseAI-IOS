//
//  MessageModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation

struct MessageModel: Identifiable, Codable {
    var id: String
    var content: String
    var from: String
    var sent_at: String
    var profile_picture: String
    var me: Bool
}
