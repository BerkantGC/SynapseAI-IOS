//
//  StoryModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

import Foundation

class StoryModel: Identifiable, Codable {
    var id: Int
    var image: String
    var user: String
    var created_at: String
    var viewer_count: Int
    var profile_picture: String?
}
