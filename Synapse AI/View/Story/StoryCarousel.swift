import Foundation
import SwiftUI
import Kingfisher

// MARK: - Enhanced Story Carousel
struct StoryCarousel: View {
    @ObservedObject var viewModel: StoryViewModel = StoryViewModel()
    let username: String
    @State private var currentIndex = 0
    @State private var progress: CGFloat = 0.0
    @State private var timerActive = true
    @State private var isPaused = false
    @State private var showUserInfo = false
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var animationNamespace: Namespace.ID
    
    private let pageWidth: CGFloat = UIScreen.main.bounds.width
    private let pageHeight: CGFloat = UIScreen.main.bounds.height
    private let storyDuration: CGFloat = 6.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Background()
                
                // Story Images
                TabView(selection: $currentIndex) {
                    ForEach(0..<viewModel.stories.count, id: \.self) { index in
                        StoryContentView(
                            story: viewModel.stories[index],
                            animationNamespace: animationNamespace,
                            geometry: geometry,
                            onTap: { location in
                                handleTapGesture(location: location, totalPages: viewModel.stories.count)
                            },
                            onLongPress: {
                                pauseStory()
                            },
                            onLongPressEnd: {
                                resumeStory()
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentIndex) { _ in
                    resetTimer()
                }
                
                // Top overlay with progress and user info
                VStack(spacing: 0) {
                    // Progress bars
                    HStack(spacing: 4) {
                        ForEach(0..<viewModel.stories.count, id: \.self) { index in
                            EnhancedProgressBar(
                                progress: index < currentIndex ? 1.0 : (index == currentIndex ? progress : 0.0),
                                isPaused: isPaused
                            )
                            .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // User info header
                    if !viewModel.stories.isEmpty {
                        StoryHeaderView(
                            story: viewModel.stories[currentIndex],
                            showUserInfo: $showUserInfo,
                            animationNamespace: animationNamespace
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                    
                    Spacer()
                    
                    // Story interaction footer
                    StoryFooterView(
                        story: viewModel.stories.isEmpty ? nil : viewModel.stories[currentIndex]
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                
                // Pause indicator
                if isPaused {
                    VStack {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 80, height: 80)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            viewModel.getUserStories(username: username)
        }
        .onReceive(timer) { _ in
            if timerActive && !isPaused {
                updateProgress(totalPages: viewModel.stories.count)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Private Methods
    private func handleTapGesture(location: CGPoint, totalPages: Int) {
        let tapZone = pageWidth / 3
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if location.x < tapZone {
                goToPreviousStory(totalPages: totalPages)
            } else if location.x > pageWidth - tapZone {
                goToNextStory(totalPages: totalPages)
            }
            // Middle tap zone does nothing (reserved for other interactions)
        }
    }
    
    private func pauseStory() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPaused = true
        }
    }
    
    private func resumeStory() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPaused = false
        }
    }
    
    private func goToNextStory(totalPages: Int) {
        currentIndex = (currentIndex + 1) % totalPages
    }
    
    private func goToPreviousStory(totalPages: Int) {
        currentIndex = (currentIndex - 1 + totalPages) % totalPages
    }
    
    private func updateProgress(totalPages: Int) {
        if progress < 1.0 {
            progress += 0.1 / storyDuration
        } else {
            progress = 0.0
            goToNextStory(totalPages: totalPages)
        }
    }
    
    private func resetTimer() {
        progress = 0.0
    }
}

// MARK: - Story Content View
struct StoryContentView: View {
    let story: StoryModel
    let animationNamespace: Namespace.ID
    let geometry: GeometryProxy
    let onTap: (CGPoint) -> Void
    let onLongPress: () -> Void
    let onLongPressEnd: () -> Void
    
    var body: some View {
        ZStack {
            KFImage(URL(string: story.image))
            .placeholder {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("Loading story...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            
            // Tap zones overlay (invisible)
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: geometry.size.width / 3)
                    .contentShape(Rectangle())
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: geometry.size.width / 3)
                    .contentShape(Rectangle())
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: geometry.size.width / 3)
                    .contentShape(Rectangle())
            }
            .onTapGesture { location in
                onTap(location)
            }
            .onLongPressGesture(
                minimumDuration: 0.1,
                maximumDistance: 50,
                pressing: { pressing in
                    if pressing {
                        onLongPress()
                    } else {
                        onLongPressEnd()
                    }
                },
                perform: {}
            )
        }
    }
}

// MARK: - Enhanced Progress Bar
struct EnhancedProgressBar: View {
    var progress: CGFloat
    var isPaused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.3))
                
                Capsule()
                    .fill(LinearGradient(
                        colors: isPaused ? [.yellow, .orange] : [.white, .white.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 3)
        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Story Header View
struct StoryHeaderView: View {
    let story: StoryModel
    @Binding var showUserInfo: Bool
    var animationNamespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile picture
            ProfileImageView(imageData: nil, imageUrl: story.profile_picture, size: 40)
            .matchedGeometryEffect(id: "story\(story.id)", in: animationNamespace)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(story.user)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(timeAgoString(from: story.created_at))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Viewer count
            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 12))
                Text("\(story.viewer_count)")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
            
            // More options
            Button(action: {
                showUserInfo.toggle()
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }
    
    private func timeAgoString(from dateString: String) -> String {
        // Implement your date parsing logic here
        // This is a placeholder implementation
        return "2h ago"
    }
}

// MARK: - Story Footer View
struct StoryFooterView: View {
    let story: StoryModel?
    @State private var isLiked = false
    @State private var showReplyField = false
    @State private var replyText = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Interaction buttons
            HStack(spacing: 20) {
                // Like button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isLiked ? .red : .white)
                        .scaleEffect(isLiked ? 1.2 : 1.0)
                }
                
                // Reply button
                Button(action: {
                    showReplyField.toggle()
                }) {
                    Image(systemName: "message")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Share button
                Button(action: {
                    // Handle share
                }) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // Reply field
            if showReplyField {
                HStack(spacing: 12) {
                    TextField("Reply to \(story?.user ?? "user")...", text: $replyText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundColor(.white)
                    
                    Button(action: {
                        // Send reply
                        replyText = ""
                        showReplyField = false
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    .disabled(replyText.isEmpty)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
