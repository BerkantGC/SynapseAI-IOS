//
//  ProfileModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import Combine

class ProfileModel: ObservableObject, Codable, Identifiable {
    var id: Int { user_id }

    @Published var user_id: Int
    @Published var first_name: String
    @Published var last_name: String
    @Published var username: String
    @Published var profile_picture: String?
    @Published var followers_count: Int
    @Published var followings_count: Int
    @Published var follow_status: FollowStatus?
    @Published var is_private: Bool
    @Published var visible: Bool

    enum CodingKeys: String, CodingKey {
        case user_id, first_name, last_name, username,
             profile_picture, followers_count,
             followings_count, follow_status, is_private, visible
    }

    init(
        user_id: Int,
        first_name: String,
        last_name: String,
        username: String,
        profile_picture: String?,
        followers_count: Int,
        followings_count: Int,
        follow_status: FollowStatus?,
        is_private: Bool,
        visible: Bool
    ) {
        self.user_id = user_id
        self.first_name = first_name
        self.last_name = last_name
        self.username = username
        self.profile_picture = profile_picture
        self.followers_count = followers_count
        self.followings_count = followings_count
        self.follow_status = follow_status
        self.is_private = is_private
        self.visible = visible
    }

    // Required for Codable with @Published
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.user_id = try container.decode(Int.self, forKey: .user_id)
        self.first_name = try container.decode(String.self, forKey: .first_name)
        self.last_name = try container.decode(String.self, forKey: .last_name)
        self.username = try container.decode(String.self, forKey: .username)
        self.profile_picture = try container.decodeIfPresent(String.self, forKey: .profile_picture)
        self.followers_count = try container.decode(Int.self, forKey: .followers_count)
        self.followings_count = try container.decode(Int.self, forKey: .followings_count)
        self.follow_status = try container.decodeIfPresent(FollowStatus.self, forKey: .follow_status)
        self.is_private = try container.decode(Bool.self, forKey: .is_private)
        self.visible = try container.decode(Bool.self, forKey: .visible)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(user_id, forKey: .user_id)
        try container.encode(first_name, forKey: .first_name)
        try container.encode(last_name, forKey: .last_name)
        try container.encode(username, forKey: .username)
        try container.encodeIfPresent(profile_picture, forKey: .profile_picture)
        try container.encode(followers_count, forKey: .followers_count)
        try container.encode(followings_count, forKey: .followings_count)
        try container.encodeIfPresent(follow_status, forKey: .follow_status)
        try container.encode(is_private, forKey: .is_private)
        try container.encode(visible, forKey: .visible)
    }
}
