//
//  UserModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation

struct User: Codable {
    var username: String
    var full_name: String?
    var email: String?
    var gender: String?
    var password: String?
    var token: String?
    var expires_at: Int?
    
    enum CodingKeys: String, CodingKey {
        case username
        case full_name
        case email
        case gender
        case token
        case expires_at
    }
}
