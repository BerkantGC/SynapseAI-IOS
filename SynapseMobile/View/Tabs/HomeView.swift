import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedStory: StoryModel?
    @State private var showStoryModal = false
    
    @State private var selectedPost: Post?
    @State private var showPostModal = false
    @Namespace private var animationNamespace

    var body: some View {
        NavigationStack{
            ZStack {
                Background()
                
                ZStack {
                    if viewModel.isLoading {
                        ProgressView("Loading posts...")
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            Section(header: Text("Hikayeler")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            ){
                                StoryList(stories: viewModel.stories,
                                          selectedStory: $selectedStory,
                                          showStoryModal: $showStoryModal,
                                          animationNamespace: animationNamespace)
                            }
                            Section(header: Text("Gönderiler")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            ){
                                LazyVStack {
                                    ForEach(viewModel.posts) { post in
                                        PostCard(post: post, animationNamespace: animationNamespace)
                                        .onTapGesture {
                                            withAnimation(.easeIn) {
                                                showPostModal.toggle()
                                                selectedPost = post
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if showStoryModal {
                    StoryModalView(story: selectedStory!, showStoryModal: $showStoryModal, animationNamespace: animationNamespace)
                } 
                
                if showPostModal {
                    if let post = selectedPost {
                        PostDetailCard(post: post, animationNamespace: animationNamespace)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedPost = nil
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Synapse AI")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "bell")
                }
            }
            .onAppear {
                viewModel.loadPosts()
                viewModel.loadStories()
            }
        }
    }
}


#Preview {
    Main()
}
