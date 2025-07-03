//
//  PostsGrid.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import SwiftUI
import Kingfisher

struct PostsGrid: View {
    var posts: [Post]
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var scrollDisabled: Bool
    var pageTitle: String
    
    @Namespace var animationNamespace: Namespace.ID
    
    init(posts: [Post], scrollDisabled: Bool = false, pageTitle: String = "Explore") {
        self.posts = posts
        self.scrollDisabled = scrollDisabled
        self.pageTitle = pageTitle
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(posts) { post in
                    NavigationLink(
                        destination: VerticalPostFeedView(
                            posts: posts,
                            selectedPost: post,
                            animationNamespace: animationNamespace,
                            title: pageTitle
                        ).navigationTransition(.zoom(sourceID: "post-image-\(post.id)", in: animationNamespace))
                    ) {
                        if post.feeling == "SMILE" {
                            VStack(spacing: 20) {
                                Image(systemName: "lock.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray)

                                Text("This post is too positive.")
                                    .font(.system(size: 10))
                            }
                            .padding(5)
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: screenHeight / 5
                            )
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                        }
                        else {
                            KFImage(URL(string: post.image ?? "placeholder")!)
                                .placeholder {
                                    Image("placeholder")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(
                                            minWidth: 0,
                                            maxWidth: .infinity,
                                            minHeight: screenHeight / 5
                                        )
                                        .aspectRatio(1, contentMode: .fit)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: screenHeight / 5
                                )
                                .aspectRatio(1, contentMode: .fit)
                                .clipped()
                                .cornerRadius(10)
                                .matchedTransitionSource(
                                    id: "post-image-\(post.id)",
                                    in: animationNamespace
                                )
                        }
                    }
                }
            }
            .padding()
        }
        .scrollDisabled(scrollDisabled)
    }
}
