//
//  PostsGrid.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI
import Kingfisher

struct PostsGrid: View {
    var posts: [Post];
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var scrollDisabled: Bool
    var isProfileFeed: Bool = false
    
    @Namespace var animationNamespace: Namespace.ID
    
    init(posts: [Post], scrollDisabled: Bool = false, isProfileFeed: Bool = false) {
        self.posts = posts
        self.scrollDisabled = scrollDisabled
        self.isProfileFeed = isProfileFeed
    }
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ForEach(self.posts) { post in
                    NavigationLink(destination:
                        VerticalPostFeedView(
                            posts: posts,
                            selectedPost: post,
                            animationNamespace: animationNamespace,
                            title: isProfileFeed ? post.profile.username : nil
                        )
                    ) {
                        KFImage(URL(string: post.image ?? "")!)
                        .placeholder{
                            Color.gray
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(10)
                                .matchedGeometryEffect(id: "post-image-\(post.id)", in: animationNamespace)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .cornerRadius(10)
                        .matchedGeometryEffect(id: "post-image-\(post.id)", in: animationNamespace)
                    }

                }
            }
            .padding()
        }.scrollDisabled(scrollDisabled)
    }
}
