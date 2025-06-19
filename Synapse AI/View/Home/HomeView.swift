import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedStory: StoryModel?
    @State private var showStoryModal = false
    @ObservedObject private var socketManager = SocketManagerService.shared
    @State private var navigateToProfileId: String? = nil
    @State private var selectedPost: Post?
    @State private var showPostModal = false
    @Namespace private var animationNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                Background().ignoresSafeArea()
                
                ScrollViewReader { scrollView in
                    ScrollView {
                        if viewModel.isLoading {
                            ProgressView("Loading posts...")
                                .transition(.opacity.animation(.easeInOut))
                        } else if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                                .transition(.opacity.animation(.easeInOut))
                        } else {
                            contentScrollView
                        }
                    }.refreshable {
                        await refreshContent()
                    }
                }

                if showStoryModal, let story = selectedStory {
                    StoryModalView(
                        story: story,
                        showStoryModal: $showStoryModal,
                        animationNamespace: animationNamespace
                    )
                    .zIndex(2)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Synapse")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NotificationsView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: socketManager.notifications.count > 0 ? "bell.fill" : "bell")
                            if socketManager.notifications.count > 0 {
                                Text("\(socketManager.notifications.count)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { navigateToProfileId != nil },
                set: { if !$0 { navigateToProfileId = nil } }
            )) {
                if let id = navigateToProfileId {
                    ProfileView(username: id)
                }
            }
            .onAppear {
                viewModel.loadPosts()
                viewModel.loadStories()
            }
        }.onReceive(NotificationCenter.default.publisher(for: .navigateToProfile)) { notification in
            if let profileId = notification.object as? String {
                navigateToProfileId = profileId
            }
        }
    }

    private var contentScrollView: some View {
        
                VStack(spacing: 10) {
                    Section(header: Text("Daily") 
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)) {
                            StoryList(
                                stories: viewModel.stories,
                                selectedStory: $selectedStory,
                                showStoryModal: $showStoryModal,
                                animationNamespace: animationNamespace
                            )
                        }

                    Group {
                        if viewModel.posts.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)

                                Text("No Posts Yet")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding()
                            .transition(.opacity)
                            
                        } else {
                            Section(header: Text("Posts")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)) {

                                LazyVStack(spacing: 20) {
                                    ForEach(viewModel.posts) { post in
                                        PostCard(post: post, animationNamespace: animationNamespace)
                                            .id(post.id)
                                    }
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                .padding(.bottom, 10)
        }
    }

    private func refreshContent() async {
        await MainActor.run {
            viewModel.loadStories()
            viewModel.loadPosts()
        }
    }
}
