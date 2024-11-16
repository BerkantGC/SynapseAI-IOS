import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedStory: StoryModel?
    @State private var showStoryModal = false
    @Namespace private var animationNamespace

    var body: some View {
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
                                    PostCard(post: post)
                                }
                            }
                        }
                    }
                }
            }
        
            if showStoryModal {
                StoryModalView(story: selectedStory!, showStoryModal: $showStoryModal, animationNamespace: animationNamespace)
            }
        }.navigationTitle("SynapseAI")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadPosts()
            viewModel.loadStories()
        }
    }
}


struct StoryModalView: View {
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    let story: StoryModel
    @Binding var showStoryModal: Bool
    var animationNamespace: Namespace.ID

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
                    showStoryModal = false
                }
            }
            
            VStack {
                Spacer()
                AsyncImage(url: URL(string: "http://localhost:8080/image/\(story.image).png")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: story.id, in: animationNamespace)
                        .frame(width: .infinity, height: .infinity)
                }placeholder: {
                    ProgressView()
                }
                
                Text(story.user)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()

                Spacer()
            }.offset(offset)
                .scaleEffect( 1 - offset.height/UIScreen.main.bounds.height )
                .gesture(DragGesture().onChanged(onDrag).onEnded(onEnd))
        }.toolbarVisibility(.hidden, for: .tabBar)
        .zIndex(1)
    }
    
    func onDrag(_ value: DragGesture.Value) -> Void {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
            offset = value.translation
            isDragging = true
        }
    }
    
    func onEnd(_ value: DragGesture.Value) -> Void {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)) {
            if offset.height > 200 {
                showStoryModal = false
            }
            offset = .zero
            isDragging = false
        }
    }
}

#Preview {
    Main()
}
