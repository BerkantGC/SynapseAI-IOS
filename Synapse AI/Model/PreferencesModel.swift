//
//  PreferencesModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

struct PreferencesModel: Decodable {
    let is_private: Bool
    let gender: String
    let city: String
    let birthday: String
    let bio: String
}
