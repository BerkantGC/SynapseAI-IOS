//
//  PostsGrid.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

struct PostsGrid: View {
    var posts: [Post];
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var scrollDisabled: Bool
    
    init(posts: [Post], scrollDisabled: Bool = false) {
        self.posts = posts
        self.scrollDisabled = scrollDisabled
    }
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ForEach(self.posts) { post in
                    AsyncImage(url: URL(string: post.image ?? "")!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(10)
                    } placeholder: {
                        Image("placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }.scrollDisabled(scrollDisabled)
    }
}
