//
//  PostViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

import Foundation
import SwiftUI

class PostViewModel: ObservableObject {
    @Published var isLoading: Bool;
    @Published var post: Post;
    
    init(isLoading: Bool = false, post: Post) {
        self.isLoading = isLoading
        self.post = post
    }
    
    // MARK: - Actions
    func toggleLike() {
        guard !isLoading else { return }
        
        isLoading = true
        let wasLiked = post.liked ?? false
        
        // Optimistic update
        post.liked = !wasLiked
        post.likes_count = (post.likes_count ?? 0) + (wasLiked ? -1 : 1)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        FetchService().executeRequest(
            url: "/posts/\(post.id)/like",
            method: "PUT",
            data: nil
        ) { response, data, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Like error: \(error)")
                    // Revert optimistic update on error
                    self.post.liked = wasLiked
                    self.post.likes_count = (self.post.likes_count ?? 0) + (wasLiked ? 1 : -1)
                }
            }
        }
    }
    
    func toggleBookmark() {
        guard !isLoading else { return }
        
        isLoading = true
        
        let wasBookmarked = post.favorite;
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        
        FetchService().executeRequest(url: "/profile/favorites", method: "POST", data: ["post_id": post.id]) { data, response, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Bookmark error: \(error)")
                } else {
                    self.post.favorite = !wasBookmarked
                    impactFeedback.impactOccurred()
                }
                
                self.isLoading = false
            }
        }
    }

}
