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
    
    func loadComments(postId: Int) {
        FetchService().executeRequest(url: "/comments?post_id=\(postId)", method: "GET", data: nil) { data, response, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let data = data {
                do {
                    let comments = try JSONDecoder().decode([CommentModel].self, from: data)
                    self.comments = comments
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
