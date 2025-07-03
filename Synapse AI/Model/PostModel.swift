//
//  PostModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation

struct Post: Identifiable, Codable, Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int  // unique identifier
    var title: String?
    var content: String?
    var image: String?
    var prompt: String?
    var created_at: String
    var profile: ProfileModel
    var video: String?
    var processing_status: String?
    var liked: Bool?
    var favorite: Bool
    var likes_count: Int?
    var feeling: String?
    var comments_count: Int?
    var top_comments: [CommentModel]?
    var enhanced_prompt: String?
    var old_image: String?
}
