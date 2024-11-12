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
        print(post)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .opacity(0.01)
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
                }.padding(.horizontal)
                AsyncImage(url: URL(string: "http://localhost:8080/image/\(post.image ?? "").png")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                HStack {
                    Button(){
                        FetchService().executeRequest(url: "/posts/\(post.id)/like", method: "PUT", data: nil){ response,data,error in
                            
                            if let error = error {
                                print(error)
                                return
                            }
                            
                            if data != nil {
                                post.liked! ?
                                    (post.likes_count! -= 1) :
                                    (post.likes_count! += 1)
                                post.liked = !post.liked!
                            }
                        }
                        
                    }label: {
                        HStack(spacing: 5){
                            Image(systemName: post.liked! ? "heart.fill" : "heart").font(.title2)
                            Text("\(post.likes_count!)")
                        }
                    }
                    Button(){
                        print("Comment")
                    }label: {
                        HStack(spacing: 5){
                            Image(systemName: "bubble.left").font(.title2)
                            Text("\(post.comments_count!)")
                        }
                    }
                    Button(){
                        print("Share")
                    }label: {
                        Image(systemName: "paperplane").font(.title2)
                    }
                    Spacer()
                    Button(){
                        print("Bookmark")
                    }label: {
                        Image(systemName: "bookmark").font(.title2)
                    }
                }.padding()
            }
        }
        .frame(maxWidth: .infinity,
                maxHeight: UIScreen.main.bounds.height / 2
         )
    }
}
