//
//  UserModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation

struct User: Decodable {
    var username: String
    var password: String?
    var token: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case token
    }
}
