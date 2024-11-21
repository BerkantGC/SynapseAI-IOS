//
//  SessionModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 21.11.2024.
//

import Foundation

struct SessionModel:  Identifiable,Codable {
    var id: String
    var last_message: String?
    var last_message_date: String?
    var user: String
    var image: String?
    var group_id: String?
    var created_at: String?
    
}
