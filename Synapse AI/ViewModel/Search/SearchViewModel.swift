//
//  SearchViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 24.11.2024.
//

import Foundation


class SearchViewModel: ObservableObject {
    @Published var users: [UserSearchModel] = []
    @Published var errorMessage: String?
    @Published var posts: [Post] = []
    @Published var recommendations: [FollowModel] = []
    
    func searchUsers(query: String) {
        FetchService().executeRequest(url: "/search/users?name=\(query)", method: "GET", data: nil) { data, response, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let data = data {
                do {
                    let users = try JSONDecoder().decode([UserSearchModel].self, from: data)
                    
                    self.users = users
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchExplorePosts() async{
        await FetchService().executeRequest(url: "/explore", method: "GET", data: nil) { data, response, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        let posts = try JSONDecoder().decode([Post].self, from: data)
                        
                        self.posts = posts
                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func fetchFollowRecommendations() async {
        await FetchService().executeRequest(url: "/profile/friend-recommendations", method: "GET", data: nil) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
        
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }

            do {
                let recommendations = try JSONDecoder().decode([FollowModel].self, from: data)
                DispatchQueue.main.async {
                    self.recommendations = recommendations
                }
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("RAW JSON: \(jsonString)")
                }
                print("Decoding failed: \(error)")
            }
        }
    }

}
