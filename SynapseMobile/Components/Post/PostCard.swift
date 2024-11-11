//
//  PostCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation
import SwiftUI

struct PostCard: View {
    @State var post: Post;
    
    init(post: Post) {
        self.post = post;
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
            VStack {
                HStack {
                    AsyncImage(url: URL(string: "http://localhost:8080/image/\(post.profile_picture ?? "").png")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                    VStack(alignment: .leading) {
                        Text(post.full_name!)
                            .font(.headline)
                        Text("11.11.2024")
                            .font(.subheadline)
                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .padding()
                }
                AsyncImage(url: URL(string: "http://localhost:8080/image/\(post.image ?? "").png")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                HStack {
                    Image(systemName: "heart.fill").imageScale(.large)
                    Image(systemName: "bubble.right").imageScale(.large)
                    Image(systemName: "paperplane").imageScale(.large)
                    Spacer()
                    Image(systemName: "bookmark").imageScale(.large)
                }
            }.padding()
        }.frame(maxWidth: .infinity,
                maxHeight: UIScreen.main.bounds.height / 2,
                alignment: .topLeading
         )
    }
}
