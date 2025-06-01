//
//  PostDetailCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

struct PostDetailCard: View {
    @ObservedObject private var viewModel: PostViewModel
    @State private var showCommentSheet = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showShareSheet = false
    @State private var headerOpacity: Double = 0
    @State private var imageScale: CGFloat = 1.0
    @State private var isImageFullscreen = false
    @State private var imageOffset: CGFloat = 0
    @State private var buttonPresses: [String: Bool] = [:]
    @Environment(\.dismiss) var dismiss
    
    private var post: Post {
        get { viewModel.post }
        set { viewModel.post = newValue }
    }

    let animationNamespace: Namespace.ID
    private let headerHeight: CGFloat = 100
    
    init(viewModel: PostViewModel, animationNamespace: Namespace.ID) {
        self.viewModel = viewModel
        self.animationNamespace = animationNamespace
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main Content
            ScrollView {
                VStack(spacing: 0) {
                    heroImageSection
                    if !isImageFullscreen {
                        contentCard
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)).animation(.spring(response: 0.6, dampingFraction: 0.8)),
                                    removal: .opacity.combined(with: .scale(scale: 1.05)).animation(.easeInOut(duration: 0.4))
                                )
                            )
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .ignoresSafeArea(.container, edges: .vertical)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                headerOpacity = min(max(0, (value - 150) / CGFloat(100)), 1)

                if value < 0 {
                    withAnimation(.easeOut(duration: 0.15)) {
                        imageScale = 1.0 + min((-value) / 300, 0.5)
                        imageOffset = value * 0.5
                    }
                } else if value > 0 {
                    withAnimation(.easeOut(duration: 0.15)) {
                        imageScale = max(0.8, 1.0 - (value / 800))
                        imageOffset = -value * 0.3
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.15)) {
                        imageScale = 1.0
                        imageOffset = 0
                    }
                }
            }
            
            
            // Floating Header with smooth transition
            floatingHeader
                .opacity(isImageFullscreen ? 0 : headerOpacity)
                    .offset(y: (isImageFullscreen || headerOpacity == 0) ? -100 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isImageFullscreen)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showCommentSheet) {
            CommentView(parentPost: $viewModel.post)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareContent])
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                imageScale = 1.0
            }
        }
    }
    
    // MARK: - Hero Image Section
    private var heroImageSection: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: post.image ?? "")) { image in
                image
                    .resizable()
                    .matchedGeometryEffect(id: post.id, in: animationNamespace)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .scaleEffect(imageScale)
                    .offset(y: imageOffset)
                    .overlay(
                        // Enhanced gradient overlay
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.black.opacity(0.3), location: 0.0),
                                .init(color: Color.clear, location: 0.3),
                                .init(color: Color.clear, location: 0.7),
                                .init(color: Color.black.opacity(0.5), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isImageFullscreen.toggle()
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: imageScale)
            } placeholder: {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        VStack {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.white)
                            Text("Loading...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 8)
                        }
                    )
            }
        }
        .frame(height: isImageFullscreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height * 0.6)
        .overlay(alignment: .topLeading) {
            backButton
                .padding(.top, 50)
                .padding(.leading, 20)
        }
        .overlay(alignment: .bottomTrailing) {
            quickActionButtons
                .padding(.bottom, 50)
                .padding(.trailing, 20)
        }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
        )
    }
    
    // MARK: - Back Button with enhanced animation
    private var backButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dismiss()
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(buttonPresses["back"] == true ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                buttonPresses["back"] = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    buttonPresses["back"] = false
                }
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dismiss()
            }
        }
    }
    
    // MARK: - Quick Action Buttons with enhanced animations
    private var quickActionButtons: some View {
        VStack(spacing: 16) {
            // Like Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    viewModel.toggleLike()
                }
            } label: {
                Image(systemName: post.liked == true ? "heart.fill" : "heart")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(post.liked == true ? .red : .white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.isLoading)
            .scaleEffect(post.liked == true ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: post.liked)
            
            // Comment Button
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showCommentSheet.toggle()
                }
            } label: {
                Image(systemName: "bubble.left")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(buttonPresses["comment"] == true ? 0.95 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    buttonPresses["comment"] = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonPresses["comment"] = false
                    }
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showCommentSheet.toggle()
                }
            }
            
            // Bookmark Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleBookmark()
                }
            } label: {
                Image(systemName: post.favorite ? "bookmark.fill" : "bookmark")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(post.favorite ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: post.favorite)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Content Card with entrance animation
    private var contentCard: some View {
        VStack(spacing: 0) {
            // User Info Header
            userInfoHeader
                .padding(.horizontal, 24)
                .padding(.top, 24)
            
            // Post Content
            postContent
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            
            Divider()
                .padding(.horizontal, 24)
                .opacity(0.6)
            
            // Engagement Stats
            engagementStats
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            
            Divider()
                .padding(.horizontal, 24)
                .opacity(0.6)
            
            // Comments Preview
            commentsPreview
                .padding(.bottom, 40)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -10)
        .offset(y: -30)
    }
    
    // MARK: - Floating Header
    private var floatingHeader: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            profileImageView
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(post.profile.first_name) \(post.profile.last_name)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("@\(post.profile.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                // More options
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.regularMaterial)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    // MARK: - User Info Header
    var followStatusText: String {
        switch post.profile.follow_status {
        case .ACCEPTED:
            return "Following"
        case .PENDING:
            return "Requested"
        case .REJECTED:
            return "Follow"
        default:
            return "Follow"
        }
    }
    
    private var userInfoHeader: some View {
        HStack(spacing: 12) {
            profileImageView
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(post.profile.first_name) \(post.profile.last_name)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text("@\(post.profile.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                // Follow/Unfollow functionality
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    // Handle follow action
                }
            } label: {
                Text(followStatusText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(post.profile.follow_status == .ACCEPTED ? .primary : .white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(post.profile.follow_status == .ACCEPTED ?
                                  Color.gray.opacity(0.2) : Color.blue)
                    )
            }
            .scaleEffect(buttonPresses["follow"] == true ? 0.95 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    buttonPresses["follow"] = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonPresses["follow"] = false
                    }
                }
            }
        }
    }
    
    private var profileImageView: some View {
        Group {
            if let profilePicture = post.profile.profile_picture {
                AsyncImage(url: URL(string: profilePicture)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    )
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Post Content
    private var postContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
            }
            
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
                    .foregroundColor(.primary.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Engagement Stats
    private var engagementStats: some View {
        HStack(spacing: 24) {
            HStack(spacing: 6) {
                Text("\(post.likes_count ?? 0)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("likes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 6) {
                Text("\(post.comments_count ?? 0)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("comments")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showShareSheet.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
            }
            .scaleEffect(buttonPresses["share"] == true ? 0.95 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    buttonPresses["share"] = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonPresses["share"] = false
                    }
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showShareSheet.toggle()
                }
            }
        }
    }
    
    // MARK: - Comments Preview
    private var commentsPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Comments")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showCommentSheet.toggle()
                    }
                } label: {
                    Text("View All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                }
            }
            
            // Comments list
            VStack(alignment: .leading, spacing: 16) {
                if let topComments = post.top_comments, !topComments.isEmpty {
                    ForEach(Array(topComments.prefix(2).enumerated()), id: \.element.id) { index, comment in
                        UserCommentCard(comment: comment)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1 * Double(index)), value: topComments)
                    }
                } else {
                    HStack {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.secondary.opacity(0.7))
                        Text("No comments yet. Be the first to comment!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var shareContent: String {
        return "Check out this post: \(post.title ?? "")"
    }
}

// MARK: - Helper Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
