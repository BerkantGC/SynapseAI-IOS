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
    var pageTitle: String
    
    @Namespace var animationNamespace: Namespace.ID
    
    init(posts: [Post], scrollDisabled: Bool = false, pageTitle: String = "Explore") {
        self.posts = posts
        self.scrollDisabled = scrollDisabled
        self.pageTitle = pageTitle
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
                            title: pageTitle
                        )
                    ) {
                        KFImage(URL(string: post.image ?? "https://synapsebucket.s3.eu-north-1.amazonaws.com/emmastone__post_81079215-9bbe-43ee-ac95-a1b2552ff4b9.jpeg")!)
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
