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
                Background()
                
                if viewModel.isLoading {
                    ProgressView("Loading posts...")
                        .transition(.opacity.animation(.easeInOut))
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .transition(.opacity.animation(.easeInOut))
                } else {
                    ScrollViewReader { scrollView in
                        ScrollView {
                            Section(header: Text("Hikayeler")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            ) {
                                StoryList(stories: viewModel.stories,
                                          selectedStory: $selectedStory,
                                          showStoryModal: $showStoryModal,
                                          animationNamespace: animationNamespace)
                            }
                            Section(header: Text("Gönderiler")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            ) {
                                LazyVStack {
                                    ForEach(viewModel.posts) { post in
                                        PostCard(post: post, animationNamespace: animationNamespace)
                                            .onTapGesture {
                                                scrollView.scrollTo(post.id, anchor: .center)
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)
                                                    .delay(0.1)) {
                                                    selectedPost = post
                                                    showPostModal.toggle()
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            await refreshContent()
                        }
                    }
                }
                
                // Story Modal with Smooth Transition
                if showStoryModal {
                    StoryModalView(story: selectedStory!, showStoryModal: $showStoryModal, animationNamespace: animationNamespace)
                }
                
                // Post Modal with Smooth Transition
                if showPostModal, let post = selectedPost {
                    PostDetailCard(post: post, animationNamespace: animationNamespace)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedPost = nil
                            }
                        }
                        .transition(.opacity.animation(.easeInOut))
                        .toolbarVisibility(.hidden, for: .tabBar)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Synapse AI")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NotificationsView()) {
                        if SocketManagerService.shared.notifications.count > 0 {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.text)
                                .overlay(
                                    Text(String(SocketManagerService.shared.notifications.count))
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .padding(5)
                                        .offset(x: 10, y: -10)
                                )
                        } else {
                            Image(systemName: "bell")
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
    
    private func refreshContent() async {
        // Load posts and stories
        viewModel.loadStories()
        viewModel.loadPosts()
    }
}

#Preview {
    Main()
}
