import SwiftUI

struct VerticalPostFeedView: View {
    let posts: [Post]
    let selectedPost: Post
    let animationNamespace: Namespace.ID
    
    private var indexOfSelected: Int? {
        posts.firstIndex(where: { $0.id == selectedPost.id })
    }
    
    var body: some View {
        ZStack {
            Background()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if let index = indexOfSelected {
                            // Posts ABOVE selected one (in reverse order)
                            ForEach(Array(posts[..<index].reversed().enumerated()), id: \.element.id) { _, post in
                                PostCard(
                                    post: post,
                                    animationNamespace: animationNamespace
                                )
                            }
                            
                            // Selected Post in center
                            PostCard(
                                post: selectedPost,
                                animationNamespace: animationNamespace
                            )
                            .id("selectedPost") // Add ID for scrolling
                            
                            // Posts BELOW selected one
                            if index + 1 < posts.count {
                                ForEach(posts[(index + 1)...], id: \.id) { post in
                                    PostCard(
                                        post: post,
                                        animationNamespace: animationNamespace
                                    )
                                }
                            }
                        } else {
                            // Fallback: if selectedPost is not found in posts array
                            ForEach(posts, id: \.id) { post in
                                PostCard(
                                    post: post,
                                    animationNamespace: animationNamespace
                                )
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onAppear {
                    // Scroll to selected post when view appears (no animation)
                    proxy.scrollTo("selectedPost", anchor: .center)
                }
            }
        }
        .navigationTitle(selectedPost.profile.username)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
