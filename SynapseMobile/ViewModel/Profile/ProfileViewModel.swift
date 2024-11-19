//
//  ProfileViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: ProfileModel?
    @Published var userPosts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var followers: [FollowModel] = []
    @Published var followings: [FollowModel] = []
    
    func loadMyDetails(){
        self.isLoading = true
        self.errorMessage = nil
        FetchService().executeRequest(url: "/profile/me", method: "GET", data: nil) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(ProfileModel.self, from: data)
                        self.profile = decodedData
                        self.loadUserPosts()
                    } catch {
                        self.errorMessage = "Error decoding JSON: \(error)"
                        print(self.errorMessage!)
                    }
                } else if let error = error {
                    self.errorMessage = "Error fetching profile: \(error)"
                    print(self.errorMessage!)
                }
            }
        }
    }
    
    func loadUserDetails(username: String){
        self.isLoading = true
        self.errorMessage = nil
        FetchService().executeRequest(url: "/profile/\(username)", method: "GET", data: nil) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(ProfileModel.self, from: data)
                        self.profile = decodedData
                        self.loadUserPosts()
                    } catch {
                        self.errorMessage = "Error decoding JSON: \(error)"
                        print(self.errorMessage!)
                    }
                } else if let error = error {
                    self.errorMessage = "Error fetching profile: \(error)"
                    print(self.errorMessage!)
                }
            }
        }
    }
    
    func loadUserPosts(){
        self.isLoading = true
        self.errorMessage = nil
        FetchService().executeRequest(url: "/profile/\(self.profile!.user_id)/posts", method: "GET", data: nil) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([Post].self, from: data)
                        self.userPosts = decodedData;
                    } catch {
                        self.errorMessage = "Error decoding JSON: \(error)"
                        print(self.errorMessage!)
                    }
                } else if let error = error {
                    self.errorMessage = "Error fetching posts: \(error)"
                    print(self.errorMessage!)
                }
            }
        }
    }
    
    func getFollowers(status: FollowStatus){
        FetchService().executeRequest(url: "/profile/\(self.profile!.user_id)/followers?status=\(status.rawValue)", method: "GET", data: nil){ data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([FollowModel].self, from: data)
                        self.followers = decodedData
                    } catch {
                        self.errorMessage = "Error decoding JSON: \(error)"
                        print(self.errorMessage!)
                    }
                } else if let error = error {
                    self.errorMessage = "Error fetching followers: \(error)"
                    print(self.errorMessage!)
                }
            }
        }
    }
    
    func getFollowings(status: FollowStatus){
        FetchService().executeRequest(url: "/profile/\(self.profile!.user_id)/followings?status=\(status.rawValue)", method: "GET", data: nil){ data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([FollowModel].self, from: data)
                        self.followings = decodedData
                    } catch {
                        self.errorMessage = "Error decoding JSON: \(error)"
                        print(self.errorMessage!)
                    }
                } else if let error = error {
                    self.errorMessage = "Error fetching followings: \(error)"
                    print(self.errorMessage!)
                }
            }
        }
    }
}
