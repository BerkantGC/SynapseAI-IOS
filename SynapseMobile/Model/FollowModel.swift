//
//  FollowModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 13.11.2024.
//

enum FollowStatus: String, Codable {
    case ACCEPTED = "ACCEPTED"
    case PENDING = "PENDING"
    case REJECTED = "REJECTED"
}

class FollowModel: Identifiable, Codable{
    var user_id: Int
    var username: String
    var fullname: String?
    var followed_at: String?
    var profile_picture: String?
    var status: FollowStatus
}
