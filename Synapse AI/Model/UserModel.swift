//
//  UserModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation

struct User: Codable {
    var username: String
    var full_name: String
    var email: String
    var gender: String?
    var token: String
    var refresh_token: String
    var expires_at: Int
    var refresh_expires_at: Int
    
    enum CodingKeys: String, CodingKey {
        case username
        case full_name
        case email
        case gender
        case token
        case refresh_token
        case expires_at
        case refresh_expires_at
    }
}
