//
//  StorylİST.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

import Foundation
import SwiftUI

struct StoryList: View {
    var stories: [StoryModel]
    @Binding var selectedStory: StoryModel?
    @Binding var showStoryModal: Bool
    var animationNamespace: Namespace.ID

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                ForEach(self.stories) { story in
                    StoryCard(story: story, animationNamespace: animationNamespace)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
                            selectedStory = story
                            showStoryModal.toggle()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


