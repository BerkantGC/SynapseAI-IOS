//
//  PostCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation
import SwiftUI
import Kingfisher

struct PostCard: View {
    @ObservedObject private var viewModel: PostViewModel
    @State private var showCommentSheet = false
    @State private var isLiking = false
    @State private var showOptions = false
    @State private var showPromptModal = false
    @State private var aiIconScale: CGFloat = 1.0
    @State private var aiIconRotation: Double = 0
    
    private var post: Post {
        get { viewModel.post }
        set { viewModel.post = newValue }
    }
    let animationNamespace: Namespace.ID
    let onImageLoad: (() -> Void)? // optional callback

    init(post: Post, animationNamespace: Namespace.ID, onImageLoad: (() -> Void)? = nil) {
        self.viewModel = PostViewModel(post: post);
        self.animationNamespace = animationNamespace
        self.onImageLoad = onImageLoad
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            postImageSection
            actionButtonsSection
            contentSection
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .clipped()
        .padding(.horizontal, 10)
        .sheet(isPresented: $showPromptModal) {
            promptModalView
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            NavigationLink(destination: ProfileView(username: post.profile.username)){
                ProfileImageView(imageData: nil, imageUrl: post.profile.profile_picture, size: 40)
                userInfoView
            }
            Spacer()
            
            moreOptionsButton
        }
        .padding()
    }
    
    private var aiGeneratedIndicator: some View {
        Button {
            showPromptModal = true
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
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
                    .frame(width: 32, height: 32)
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
    
    private var userInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(post.profile.first_name) \(post.profile.last_name)")
                .font(.headline)
                .lineLimit(1)
            
            Text("@\(post.profile.username)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    private var moreOptionsButton: some View {
        Button {
            showOptions.toggle()
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
                .padding(8)
        }
        .confirmationDialog("Post Options", isPresented: $showOptions, titleVisibility: .visible) {
            if post.profile.username == KeychainService.instance.getLoggedInUsername() {
                Button("Edit", role: .none) {
                    // Open edit screen
                }
                Button("Delete", role: .destructive) {
                    viewModel.deletePost()
                }
            } else {
                Button("Report", role: .destructive) {
                    viewModel.reportPost()
                }
            }

            Button("Copy Link") {
                if let postURL = URL(string: "https://synapseapp.com/posts/\(post.id)") {
                    UIPasteboard.general.url = postURL
                }
            }

            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - AI Prompt Modal
    private var promptModalView: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Modal Header
                VStack(spacing: 16) {
                    // Animated AI Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow, .red, .bgGradientStart]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
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
                            Text(post.prompt ?? "")
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
    
    // MARK: - Post Image Section
    private var postImageSection: some View {
        NavigationLink(destination: PostDetailCard(viewModel: viewModel, animationNamespace: animationNamespace)) {
            ZStack(alignment: .top) {
                KFImage(URL(string: post.image ?? ""))
                    .placeholder {
                        ProgressView().frame(height: 300)
                    }
                    .resizable()
                    .matchedGeometryEffect(id: post.id, in: animationNamespace)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.6)
                    .clipped()
                
                // AI Generated Icon – centered at top
                if let prompt = post.prompt, !prompt.isEmpty {
                    HStack {
                        Spacer()
                        aiGeneratedIndicator
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 12)
                }
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 20) {
            likeButton
            commentButton
            shareButton
            Spacer()
            bookmarkButton
        }
        .padding()
    }
    
    private var likeButton: some View {
        Button {
            viewModel.toggleLike()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: post.liked == true ? "heart.fill" : "heart")
                    .font(.system(size: 25))
                    .foregroundColor(post.liked == true ? .red : .primary)
                
                Text("\(post.likes_count ?? 0)")
                    .font(.subheadline)
            }
        }
        .disabled(isLiking)
        .opacity(isLiking ? 0.6 : 1.0)
    }
    
    private var commentButton: some View {
        Button {
            showCommentSheet.toggle()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "bubble.left")
                    .font(.system(size: 23))
                
                Text("\(post.comments_count ?? 0)")
                    .font(.subheadline)
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            CommentView(parentPost: $viewModel.post)
                .presentationDetents([.medium, .large])
        }
    }
    
    private var shareButton: some View {
        Button {
            //
        } label: {
            Image(systemName: "paperplane")
                .font(.system(size: 25))
        }
    }
    
    private var bookmarkButton: some View {
        Button {
            viewModel.toggleBookmark()
        } label: {
            Image(systemName: post.favorite ? "bookmark.fill" : "bookmark")
                .font(.system(size: 25))
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
            }
            
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.callout)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom)
    }

}
