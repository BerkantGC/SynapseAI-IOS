//
//  StoryCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

import Foundation
import SwiftUI

struct StoryCard: View {
    var story: StoryModel
    let animationNamespace: Namespace.ID
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: story.image)) { image in
                image.resizable()
                    .matchedGeometryEffect(id: "story\(story.id)", in: animationNamespace)
                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 2.5)
                    .clipped()
                    .cornerRadius(10)
                    .shadow(color: .text, radius: 2)
            } placeholder: {
                ProgressView()
            }
            .overlay(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
            
            
            VStack {
                AsyncImage(url: URL(string: story.profile_picture ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(.infinity)
                        .shadow(color: .text, radius: 2)
                } placeholder: {
                    ProgressView()
                }
                Text(story.user)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .shadow(radius: 2)
                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
            }
        }
    }
}
