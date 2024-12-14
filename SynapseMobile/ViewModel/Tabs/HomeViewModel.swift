//
//  HomeViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var errorMessage: String?;
    @Published var isLoading = true
    @Published var posts: [Post] = []
    @Published var stories: [StoryModel] = []
    
    func loadPosts() {
        FetchService().executeRequest(url: "/feed", method: "GET", data: nil) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([Post].self, from: data)
                    self.posts = decodedResponse
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Failed to decode posts: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadStories(){
        FetchService().executeRequest(url: "/stories", method: "GET", data: nil) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to load stories: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([StoryModel].self, from: data)
                    self.stories = decodedResponse
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Failed to decode stories: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
