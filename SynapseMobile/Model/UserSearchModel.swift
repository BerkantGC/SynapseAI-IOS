//
//  UserModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation

struct UserSearchModel: Identifiable ,Codable {
    var id: Int
    var username: String
    var fullname: String?
    var email: String?
    var profile_picture: String?
    var phone: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullname
        case email
        case profile_picture
        case phone
    }
}
