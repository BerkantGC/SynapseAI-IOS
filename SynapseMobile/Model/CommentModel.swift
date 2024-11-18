//
//  PostModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation

struct CommentModel: Identifiable, Codable {
    var id: Int  // unique identifier
    var content: String?
    var created_at: String?
    var profile_picture: String?
    var user: String
    var likes_count: Int?
    var answers_count: Int?
    var post_id: Int
    var parent_id: Int?
}
