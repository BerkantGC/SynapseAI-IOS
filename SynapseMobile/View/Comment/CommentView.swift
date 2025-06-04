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

    var body: some View {
        VStack {
            Text("Comments")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            ScrollView {
                LazyVStack {
                    ForEach(viewModel.comments) { comment in
                        UserCommentCard(comment: comment, onReply: {
                            viewModel.replyingTo = comment
                        })
                    }
                }
            }

            if let replyingTo = viewModel.replyingTo {
                HStack {
                    Text("Replying to \(replyingTo.user)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                    Button("Cancel") {
                        viewModel.replyingTo = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
            }

            HStack {
                TextField("Comment", text: $viewModel.commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button(action: {
                    guard !viewModel.commentText.isEmpty else { return }
                    
                    var isAnswer = false;
                    var payload: [String: Any] = [
                        "content": viewModel.commentText,
                        "post_id": parentPost.id
                    ]
                    
                    if let replyTarget = viewModel.replyingTo {
                        payload["parent_comment_id"] = replyTarget.id
                        isAnswer = true
                    }

                    FetchService().executeRequest(url: "/comments/comment-to-post", method: "POST", data: payload) { data, response, error in
                        guard let data = data else { return }
                        do {
                            if isAnswer {
                                let answer = try JSONDecoder().decode(AnswerModel.self, from: data)
                                DispatchQueue.main.async {
                                    if let parentIndex = viewModel.comments.firstIndex(where: { $0.id == answer.parent_id }) {
                                        viewModel.comments[parentIndex].answers.append(answer)
                                    }
                                    viewModel.commentText = ""
                                    viewModel.replyingTo = nil
                                }
                            } else {
                                let comment = try JSONDecoder().decode(CommentModel.self, from: data)
                                DispatchQueue.main.async {
                                    viewModel.comments.append(comment)
                                    parentPost.comments_count? += 1
                                    viewModel.commentText = ""
                                    viewModel.replyingTo = nil
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }) {
                    Image(systemName: "arrow.up.message")
                        .font(.title2)
                        .padding(.trailing)
                }
            }
            .padding(.vertical)
            .hideKeyboardOnTap()
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            viewModel.loadComments(postId: parentPost.id)
        }
    }
}


#Preview {
    HomeView()
}
