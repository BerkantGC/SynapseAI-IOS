//
//  ProfileView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 19.11.2024.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    var username: String
    var body: some View {
        NavigationStack{
            ZStack {
                Background()
                ScrollView {
                    VStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.top, 20)
                        } else if let profile = viewModel.profile {
                            ProfileHeader(profile: profile)
                                .environmentObject(viewModel)
                        }
                        
                        PostsGrid(posts: viewModel.userPosts)
                    }
                }
            }.onAppear {
                viewModel.loadUserDetails(username: self.username )
            }
        }
    }
}
