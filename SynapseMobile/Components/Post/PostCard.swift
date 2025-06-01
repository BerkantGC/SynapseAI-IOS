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
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            NavigationLink(destination: ProfileView(username: post.profile.username)){
                profileImageView
                userInfoView
            }
            Spacer()
            moreOptionsButton
        }
        .padding()
    }
    
    private var profileImageView: some View {
        Group {
            if let profilePicture = post.profile.profile_picture {
                AsyncImage(url: URL(string: profilePicture)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
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
    
    // MARK: - Post Image Section
    private var postImageSection: some View {
        NavigationLink(destination: PostDetailCard(viewModel: viewModel, animationNamespace: animationNamespace)) {
            KFImage(URL(string: post.image ?? ""))
                .placeholder {
                    ProgressView().frame(height: 300)
                }
                .resizable()
                .matchedGeometryEffect(id: post.id, in: animationNamespace)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.6)
                .clipped()
            
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
