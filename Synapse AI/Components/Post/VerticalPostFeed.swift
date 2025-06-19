import SwiftUI

struct VerticalPostFeedView: View {
    @State var posts: [Post]
    let selectedPost: Post
    let animationNamespace: Namespace.ID
    let title: String?
    
    @State private var hasScrolled = false
    
    private var indexOfSelected: Int? {
        posts.firstIndex(where: { $0.id == selectedPost.id })
    }
     
    var body: some View {
        ZStack {
            Background()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(posts, id: \.id) { post in
                            PostCard(
                                post: post,
                                animationNamespace: animationNamespace,
                                onDelete: {
                                    if let index = posts.firstIndex(where: { $0.id == post.id }) {
                                        posts.remove(at: index)
                                    }
                                }
                            ).id(post.id)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onAppear {
                    // Scroll only the first time
                    if !hasScrolled {
                        proxy.scrollTo(selectedPost.id, anchor: .top)
                        hasScrolled = true
                    }
                }
            }
        }
        .navigationTitle(title ?? "Explore")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
