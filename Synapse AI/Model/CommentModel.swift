//
//  PostModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation

protocol DisplayableComment {
    var id: Int { get }
    var content: String { get }
    var user: String { get }
    var likes_count: Int { get }
    var created_at: String? { get }
    var profile_picture: String? { get }
    var liked: Bool { get }
}

extension CommentModel: DisplayableComment {}
extension AnswerModel: DisplayableComment {}

struct CommentModel: Identifiable, Codable, Equatable {
    var id: Int  // unique identifier
    var content: String
    var created_at: String?
    var profile_picture: String?
    var user: String
    var likes_count: Int
    var answers_count: Int?
    var answers: [AnswerModel]
    var post_id: Int
    var liked: Bool
}

struct AnswerModel: Identifiable, Codable, Equatable {
    var id: Int  // unique identifier
    var content: String
    var created_at: String?
    var profile_picture: String?
    var user: String
    var likes_count: Int
    var post_id: Int
    var parent_id: Int?
    var liked: Bool
}
