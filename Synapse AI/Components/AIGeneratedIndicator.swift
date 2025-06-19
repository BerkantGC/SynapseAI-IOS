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
                    .font(.system(size: 14, weight: .bold))
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

struct PromptModalView: View {
    @State var prompt: String;
    @Binding var showPromptModal: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        // MARK: - AI Prompt Modal
        NavigationView {
            VStack(spacing: 0) {
                // Modal Header
                VStack(spacing: 16) {
                    AIGeneratedIndicator(size: 60)
                    .scaleEffect(1.0)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            // Animation on appear
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("Generated Content")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("This post was created using Synapse AI assistance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.vertical, 20)
                
                // Prompt Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Prompt")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(prompt)
                                .font(.callout)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showPromptModal = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
}
