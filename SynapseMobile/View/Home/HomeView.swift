import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedStory: StoryModel?
    @State private var showStoryModal = false

    @State private var selectedPost: Post?
    @State private var showPostModal = false
    @Namespace private var animationNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                Background().ignoresSafeArea()

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
                            Image(systemName: SocketManagerService.shared.notifications.count > 0 ? "bell.fill" : "bell")
                            if SocketManagerService.shared.notifications.count > 0 {
                                Text("\(SocketManagerService.shared.notifications.count)")
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
            .onAppear {
                viewModel.loadPosts()
                viewModel.loadStories()
            }
        }
    }

    private var contentScrollView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(spacing: 24) {
                    Section(header: Text("Stories")
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
                        }
                }
                .padding(.bottom, 20)
            }
            .refreshable {
                await refreshContent()
            }
        }
    }

    private func refreshContent() async {
        await MainActor.run {
            viewModel.loadStories()
            viewModel.loadPosts()
        }
    }
}
