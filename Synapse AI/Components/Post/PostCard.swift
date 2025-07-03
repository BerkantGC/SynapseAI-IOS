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
    @EnvironmentKey("BASE_URL")
    private var BASE_URL: String;
    
    @ObservedObject private var viewModel: PostViewModel
    @State private var showCommentSheet = false
    @State private var isLiking = false
    @State private var showOptions = false
    @State private var showCamera = false
    @State private var showPromptModal = false
    @State private var showShareSheet: Bool = false
    
    let onDelete: (() -> Void)?
    
    private var post: Post {
        get { viewModel.post }
        set { viewModel.post = newValue }
    }
    let animationNamespace: Namespace.ID

    init(post: Post, animationNamespace: Namespace.ID, onDelete: (() -> Void)? = nil) {
        self.viewModel = PostViewModel(post: post);
        self.animationNamespace = animationNamespace
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            if viewModel.isSmilingRequired {
                LockedPost {
                    showCamera = true
                }
            } else {
                postSection
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [shareContent])
                }
            }
            
            actionButtonsSection
            contentSection
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .clipped()
        .padding(.horizontal, 10)
        .sheet(isPresented: $showPromptModal) {
            PromptModalView(post: post, showPromptModal: $showPromptModal)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showCamera) {
            
            #if targetEnvironment(simulator)
            Button(action: {
                showCamera = false
                viewModel.unblockPost()
            }) {Text("Unlock")}
            #else
            SmileUnlockCameraView {
                // Called when smile is detected
                showCamera = false
                viewModel.unblockPost()
            }
            #endif
        }
    }
    
    private var shareContent: String {
        return "Check out this post: \(post.title ?? "") (\(post.id)), posted by \(post.profile.username). Image: \(post.image ?? "")"
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
                    Task {
                        await viewModel.deletePost(onDelete: onDelete)
                    }
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
    
    // MARK: - Post Image Section
    private var postSection: some View {
        NavigationLink(destination: PostDetailCard(viewModel: viewModel, animationNamespace: animationNamespace)
            .navigationTransition(.zoom(sourceID: "post-image-\(post.id)", in: animationNamespace))
        ) {
            ZStack(alignment: .top) {
                if let video = viewModel.post.video {
                    HLSPlayerView(url: "\(BASE_URL)\(video)", onLike: {
                        if !(post.liked)!{
                            viewModel.toggleLike()
                        }
                    },post: post, isDetail: false)
                        .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height * 0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    KFImage(URL(string: post.image ?? ""))
                        .placeholder {
                            ProgressView().frame(height: 300)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height * 0.6)
                        .clipped()
                }
                
                // AI Generated Icon – centered at top
                if post.prompt != nil || post.enhanced_prompt != nil {
                    HStack {
                        Spacer()
                        AIGeneratedIndicator(onTap: {
                            showPromptModal.toggle()
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        })
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 12)
                }
            }.matchedTransitionSource(id: "post-image-\(post.id)", in: animationNamespace)
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
            self.showShareSheet.toggle()
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
