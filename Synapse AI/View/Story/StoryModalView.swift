//
//  StoryModalView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 16.11.2024.
//

import SwiftUI

// MARK: - Enhanced Story Modal View
struct StoryModalView: View {
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    @State private var scale: CGFloat = 1.0
    
    let story: StoryModel
    @Binding var showStoryModal: Bool
    var animationNamespace: Namespace.ID
    
    var body: some View {
        ZStack {
            // Background with blur effect
            Color.black
                .opacity(0.95)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // Story content
            StoryCarousel(username: story.user, animationNamespace: animationNamespace)
                .clipShape(RoundedRectangle(cornerRadius: isDragging ? 16 : 0))
                .offset(offset)
                .scaleEffect(scale)
                .gesture(dragGesture)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
        }
        .statusBarHidden()
        .preferredColorScheme(.dark)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring()) {
                    offset = value.translation
                    isDragging = true
                    
                    // Calculate scale based on vertical drag
                    let dragAmount = abs(value.translation.height)
                    let maxDrag: CGFloat = 200
                    let scaleReduction = min(dragAmount / maxDrag * 0.1, 0.1)
                    scale = 1.0 - scaleReduction
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    if abs(value.translation.height) > 150 || abs(value.predictedEndTranslation.height) > 300 {
                        dismissModal()
                    } else {
                        offset = .zero
                        scale = 1.0
                        isDragging = false
                    }
                }
            }
    }
    
    private func dismissModal() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showStoryModal = false
        }
    }
}
