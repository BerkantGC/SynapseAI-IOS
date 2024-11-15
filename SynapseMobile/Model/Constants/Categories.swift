//
//  Categories.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

enum Category : String, CaseIterable, Identifiable {
    case animal
    case anime
    case art
    case future
    case nature
    case portrait
    case technology
    case travel
    
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}
