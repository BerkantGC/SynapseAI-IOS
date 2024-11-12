//
//  ProfileModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

class ProfileModel : Decodable {
    var user_id: Int
    var first_name: String?
    var last_name: String?
    var username: String
    var profile_picture: String?
    var followers_count: Int
    var followings_count: Int
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case first_name
        case last_name
        case username
        case profile_picture
        case followers_count
        case followings_count
    }
}
