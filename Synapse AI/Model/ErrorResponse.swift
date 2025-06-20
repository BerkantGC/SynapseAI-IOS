//
//  ErrorResponse.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 20.06.2025.
//

struct ErrorResponse: Codable {
    let timestamp: String
    let status: Int
    let error: String
    let message: String
    let path: String
}
