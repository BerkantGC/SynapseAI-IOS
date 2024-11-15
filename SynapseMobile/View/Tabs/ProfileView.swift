//
//  ProfileView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel:ProfileViewModel = ProfileViewModel()
    
    var body: some View {
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
                    //ProfileStats()
                    PostsGrid(posts: viewModel.userPosts)
                }
            }
        }
    }
}

#Preview {
    Main()
}
