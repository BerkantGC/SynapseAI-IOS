//
//  EnhanceModalView.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 21.06.2025.
//

import SwiftUI
import Kingfisher

struct EnhanceModalView: View {
    var image: URL
    var prompt: String?
    var postID: Int
    @StateObject private var viewModel = EnhanceModalViewModel()
    @Binding var showEnhanceModal: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Modal Header
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            HStack {
                                Spacer()
                                AIGeneratedIndicator()
                                Text("Enhance Content")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                Text("Refine your AI-generated content")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(width: UIScreen.main.bounds.width, alignment: .center)
                        
                        
                        // Image comparison
                        HStack(spacing: 12) {
                            // Original Image
                            VStack(spacing: 8) {
                                KFImage(image)
                                    .placeholder {
                                        Image("placeholder")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: UIScreen.main.bounds.width/2.5, height: 200)
                                            .aspectRatio(1, contentMode: .fit)
                                            .clipped()
                                            .cornerRadius(10)
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width/2.5, height: 200)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipped()
                                    .cornerRadius(10)
                                    .fullScreenOnTap(imageUrl: image)
                                    
                                
                                Text("Original")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Enhanced Image
                            VStack(spacing: 8) {
                                Group {
                                    if let newImageUrl = viewModel.newImageUrl, let url = URL(string: newImageUrl) {
                                        KFImage(url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: UIScreen.main.bounds.width/2.5, height: 200)
                                            .aspectRatio(1, contentMode: .fit)
                                            .clipped()
                                            .cornerRadius(10)
                                            .fullScreenOnTap(imageUrl: url)

                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: UIScreen.main.bounds.width/2.5, height: 200)
                                            .aspectRatio(1, contentMode: .fit)
                                            .overlay(
                                                VStack(spacing: 8) {
                                                    if viewModel.isLoading {
                                                        ProgressView()
                                                            .scaleEffect(1.2)
                                                    } else {
                                                        Image(systemName: "photo")
                                                            .font(.system(size: 40))
                                                            .foregroundColor(.gray)
                                                    }
                                                    
                                                    Text(viewModel.isLoading ? "Generating..." : "Enhanced Image")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            )
                                    }
                                }
                                
                                Text("Enhanced")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                    }.hideKeyboardOnTap()
                    .padding(.top, 20)
                    
                    Divider().padding(.vertical, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Original Prompt Section
                        if let prompt = prompt {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Original Prompt")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
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
                            }.hideKeyboardOnTap()
                        }
                        
                        // Enhanced Prompt Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enhanced Prompt")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            TextEditor(text: $viewModel.enhancedPrompt)
                                .font(.callout)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .frame(minHeight: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Generate Button
                            Button {
                                Task {
                                    await viewModel.enhanceImage(postID: postID, imageURL: image.absoluteString)
                                }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "sparkles")
                                    }
                                    Text(viewModel.isLoading ? "Generating..." : "Generate Enhanced")
                                }
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.yellow, .red, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .opacity(viewModel.enhancedPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                            }
                            .disabled(viewModel.isLoading || viewModel.enhancedPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            // Apply Button
                            Button {
                                Task {
                                    await viewModel.replaceImage(postID: postID)
                                    await MainActor.run {
                                        showEnhanceModal = false
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Apply Changes")
                                }
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                                .opacity(viewModel.newImageUrl != nil ? 1.0 : 0.6)
                            }
                            .disabled(viewModel.newImageUrl == nil || viewModel.isLoading)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showEnhanceModal = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showEnhanceModal = false
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

import SwiftUI
import Kingfisher

struct PromptModalView: View {
    var post: Post
    
    @Binding var showPromptModal: Bool
    @Environment(\.presentationMode) var presentationMode
    
    init(post: Post, showPromptModal: Binding<Bool>) {
        self.post = post
        self._showPromptModal = showPromptModal
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Modal Header
                VStack(spacing: 16) {
                    AIGeneratedIndicator(size: 60)
                        
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
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Original Image (if available)
                        if let image = post.old_image, !image.isEmpty {
                            imageSection(title: "Original Image", imageUrl: image)
                        }
                        
                        // New Generated Image (if available)
                        if let newImage = post.image, !newImage.isEmpty {
                            imageSection(title: "Generated Image", imageUrl: newImage)
                        }
                        
                        // Original Prompt (if available)
                        if let prompt = post.prompt, !prompt.isEmpty {
                            promptSection(title: "Original Prompt", content: prompt)
                        }
                        
                        // Enhanced Prompt
                        if let enhancedPrompt = post.enhanced_prompt, !enhancedPrompt.isEmpty {
                            promptSection(title: "Enhanced Prompt", content: enhancedPrompt)
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
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func imageSection(title: String, imageUrl: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            KFImage(URL(string: imageUrl))
                .placeholder {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.2)
                        )
                }
                .retry(maxCount: 3)
                .onSuccess { result in
                    print("Image loaded successfully: \(imageUrl)")
                }
                .onFailure { error in
                    print("Failed to load image: \(error.localizedDescription)")
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    @ViewBuilder
    private func promptSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(content)
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
    }
}
