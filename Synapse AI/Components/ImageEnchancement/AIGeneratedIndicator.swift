//
//  AIGeneratedIndicator.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 20.06.2025.
//

import SwiftUI

struct AIGeneratedIndicator: View {
    @State private var aiIconScale: CGFloat = 1.0
    @State private var aiIconRotation: Double = 0
    @State var onTap: (()->Void)? = nil;
    
    var size: CGFloat? = 32

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack {
                // Animated background circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .red, .bgGradientStart]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .scaleEffect(aiIconScale)
                    .rotationEffect(.degrees(aiIconRotation))
                
                // AI sparkle icon
                Image(systemName: "sparkles")
                    .font(.system(size: size! * 0.435, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
        }
        .onAppear {
            // Start continuous animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                aiIconScale = 1.1
            }
            
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                aiIconRotation = 360
            }
        }
    }
}
