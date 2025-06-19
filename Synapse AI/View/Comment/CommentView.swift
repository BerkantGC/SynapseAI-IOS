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
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Comments")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            // Error message display
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // Loading indicator
            if isLoading && viewModel.comments.isEmpty {
                ProgressView("Loading comments...")
                    .padding()
            }

            ScrollView {
                LazyVStack {
                    ForEach(viewModel.comments) { comment in
                        UserCommentCard(comment: comment, onReply: {
                            viewModel.replyingTo = comment
                        })
                    }
                    
                    // Show message if no comments
                    if !isLoading && viewModel.comments.isEmpty {
                        Text("No comments yet")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .refreshable {
                await refreshComments()
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
                    submitComment()
                }) {
                    Image(systemName: "arrow.up.message")
                        .font(.title2)
                        .padding(.trailing)
                }
                .disabled(viewModel.commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.vertical)
            .hideKeyboardOnTap()
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            loadCommentsWithErrorHandling()
        }
        .onDisappear {
            viewModel.comments.removeAll()
            errorMessage = nil
        }
    }
    
    private func loadCommentsWithErrorHandling() {
        isLoading = true
        errorMessage = nil
        
        // Add debug print
        print("Loading comments for post ID: \(parentPost.id)")
        
        viewModel.loadComments(postId: parentPost.id)
    }
    
    private func refreshComments() async {
        viewModel.loadComments(postId: parentPost.id)
    }
    
    private func submitComment() {
        let trimmedText = viewModel.commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        var isAnswer = false
        var payload: [String: Any] = [
            "content": trimmedText,
            "post_id": parentPost.id
        ]
        
        if let replyTarget = viewModel.replyingTo {
            payload["parent_comment_id"] = replyTarget.id
            isAnswer = true
        }
        
        print("Submitting comment with payload: \(payload)")

        FetchService().executeRequest(url: "/comments/comment-to-post", method: "POST", data: payload) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error submitting comment: \(error)")
                    errorMessage = "Failed to submit comment"
                    return
                }
                
                guard let data = data else {
                    print("No data received from comment submission")
                    errorMessage = "No response from server"
                    return
                }
                
                do {
                    if isAnswer {
                        let answer = try JSONDecoder().decode(AnswerModel.self, from: data)
                        if let parentIndex = viewModel.comments.firstIndex(where: { $0.id == answer.parent_id }) {
                            viewModel.comments[parentIndex].answers.append(answer)
                        }
                        viewModel.commentText = ""
                        viewModel.replyingTo = nil
                    } else {
                        let comment = try JSONDecoder().decode(CommentModel.self, from: data)
                        viewModel.comments.append(comment)
                        if parentPost.comments_count != nil {
                            parentPost.comments_count! += 1
                        }
                        viewModel.commentText = ""
                        viewModel.replyingTo = nil
                    }
                } catch {
                    print("Error decoding comment response: \(error)")
                    errorMessage = "Failed to process server response"
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
