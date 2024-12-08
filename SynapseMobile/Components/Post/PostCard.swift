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
    @State var showCommentSheet: Bool = false;
    var animationNamespace: Namespace.ID
    
    var body: some View {
        ZStack {
            NavigationStack{
                VStack(spacing: 0) {
                    HStack {
                        AsyncImage(url: URL(string: post.profile_picture ?? "")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                        }
                        VStack(alignment: .leading) {
                            Text(post.full_name!)
                                .font(.headline)
                            Text("@\(post.username!)")
                                .font(.subheadline)
                        }
                        Spacer()
                        Image(systemName: "ellipsis")
                            .padding()
                    }.padding()
                    
                        AsyncImage(url: URL(string: post.image ?? "")) { image in
                            image
                                .resizable()
                                .matchedGeometryEffect(id: post.id,
                                                       in: animationNamespace)
                                .aspectRatio(contentMode: .fill)
                                
                                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.60)
                                .clipped()
                                .zIndex(4)
                        } placeholder: {
                            ProgressView()
                        }.zIndex(4)
                        
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
                            self.showCommentSheet.toggle()
                        }label: {
                            HStack(spacing: 5){
                                Image(systemName: "bubble.left").font(.title2)
                                Text("\(post.comments_count!)")
                            }
                        }.sheet(isPresented: $showCommentSheet){
                            CommentView(parentPost: self.$post)
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
                    VStack(spacing: 5){
                        Text(post.title!)
                            .font(.headline)
                        if post.content != nil {
                            Text(post.content!)
                                .font(.callout)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }.padding(.bottom)
                        .padding(.horizontal)
                }.background(.ultraThinMaterial)
            }
            .cornerRadius(20)
        }
    }
}
