//
//  CommentView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 17.11.2024.
//

import Foundation
import SwiftUI

struct CommentView : View {
    @StateObject private var viewModel = CommentViewModel()
    @Binding var parentPost: Post
    
    var body: some View{
        VStack{
            Text("Comments")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            ScrollView{
                LazyVStack{
                    ForEach(viewModel.comments){ comment in
                        UserCommentCard(comment: comment)
                    }
                }
            }
            Spacer()
            HStack{
                TextField("Comment", text: $viewModel.commentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button(action: {
                    if viewModel.commentText.count < 1 {
                        return
                    }
                    
                    FetchService().executeRequest(url: "/comments/comment-to-post", method: "POST", data: ["post_id": self.parentPost.id, "content": viewModel.commentText]) { data, response, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        if let data = data {
                            do {
                                let comment = try JSONDecoder().decode(CommentModel.self, from: data)
                                viewModel.comments.append(comment)
                                parentPost.comments_count! += 1
                                viewModel.commentText = ""
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }){
                    Image(systemName: "arrow.up.message")
                        .font(.title2)
                        .padding(.trailing)
                }
            }.padding(.vertical)

        }.onAppear{
            viewModel.loadComments(postId: self.parentPost.id)
        }
    }
}

#Preview {
    HomeView()
}
