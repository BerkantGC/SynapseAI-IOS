//
//  StoryModalView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 16.11.2024.
//

import SwiftUI

struct StoryModalView: View {
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    let story: StoryModel
    @Binding var showStoryModal: Bool
    var animationNamespace: Namespace.ID

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
                    showStoryModal = false
                }
            }
            
            VStack {
                Spacer()
                StoryCarousel(storyList: [story], animationNamespace: animationNamespace)
                    .frame(width: .infinity, height: .infinity)
                Spacer()
            }.offset(offset)
                .scaleEffect( 1 - offset.height/UIScreen.main.bounds.height )
                .gesture(DragGesture().onChanged(onDrag).onEnded(onEnd))
        }.toolbarVisibility(.hidden, for: .tabBar, .navigationBar)
        .zIndex(1)
    }
    
    func onDrag(_ value: DragGesture.Value) -> Void {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
            offset = value.translation
            isDragging = true
        }
    }
    
    func onEnd(_ value: DragGesture.Value) -> Void {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
            if offset.height > 200 {
                showStoryModal = false
            }
            offset = .zero
            isDragging = false
        }
    }
}
