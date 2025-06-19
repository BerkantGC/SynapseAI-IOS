//
//  CommentViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 17.11.2024.
//

import Foundation

class CommentViewModel: ObservableObject {
    @Published var comments: [CommentModel] = []
    @Published var errorMessage: String?
    @Published var commentText: String = ""
    @Published var replyingTo: CommentModel?
    
    func loadComments(postId: Int) {
        FetchService().executeRequest(url: "/comments?post_id=\(postId)", method: "GET", data: nil) { data, response, error in
    
            // Check if this endpoint worked
            if error == nil,
               let data = data,
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                
                do {
                    let fetchedComments = try JSONDecoder().decode([CommentModel].self, from: data)
                    self.comments = fetchedComments
                    return
                } catch {
                    print("Failed to decode from: \(error)")
                }
            }
        }
    }
}
