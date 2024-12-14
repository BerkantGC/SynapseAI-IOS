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
    
    func fetchExplorePosts() {
        FetchService().executeRequest(url: "/explore", method: "GET", data: nil) { data, response, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let data = data {
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
