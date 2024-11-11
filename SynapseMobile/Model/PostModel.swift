//
//  PostModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation

struct Post: Identifiable, Codable {
    var id: Int  // unique identifier
    var title: String?
    var content: String?
    var image: String?
    var created_at: String?
    var profile_picture: String?
    var full_name: String?
    var username: String?
}
