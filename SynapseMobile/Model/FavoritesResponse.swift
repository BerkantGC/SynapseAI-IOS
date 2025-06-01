//
//  FavoritesResponse.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

struct FavoritesResponse: Codable {
    var favorites: [Post]
    var total: Int
    var page: Int
    var size: Int
}
