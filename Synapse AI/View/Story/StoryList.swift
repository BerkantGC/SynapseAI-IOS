//
//  StoryList.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//
import Foundation
import SwiftUI

// MARK: - Enhanced Story List
struct StoryList: View {
    var stories: [StoryModel]
    @Binding var selectedStory: StoryModel?
    @Binding var showStoryModal: Bool
    var animationNamespace: Namespace.ID
    
    var body: some View {
        if stories.isEmpty {
            EmptyStoryView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(stories) { story in
                        StoryCard(
                            story: story,
                            animationNamespace: animationNamespace,
                            onTap: {
                                print("Story card tapped: \(story.user)") // Debug print
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
                                    selectedStory = story
                                    showStoryModal = true
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.05), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

// MARK: - Empty Story View
struct EmptyStoryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.secondary)
            
            Text("No Stories Yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Stories from your connections will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.02), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
