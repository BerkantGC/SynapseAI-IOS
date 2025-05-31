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
                        } else if viewModel.profile != nil {
                            ProfileHeader()
                                .environmentObject(viewModel)
                        }
                        
                        if viewModel.isPrivate {
                            VStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)

                                Text("This profile is private")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text("Follow to see this user's posts.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            PostsGrid(posts: viewModel.userPosts)
                        }

                    }
                }
            }.onAppear {
                viewModel.loadUserDetails(username: self.username )
            }
        }
    }
}
