//
//  ProfileHeader.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI
import PhotosUI
import Kingfisher

struct ProfileHeader : View {
    @EnvironmentObject var viewModel: ProfileViewModel
    @State var showFollows = false
    @State var selectedSegment: String = "followers"
    @State var selection: PhotosPickerItem?
    @State var selectedImageData: UIImage?
    @State private var isCropperPresented = false
    @State private var selectedUser: String?
    
    private var currentSession: User?
    private var isMe: Bool
    
    init(isMe: Bool = false) {
        self.isMe = isMe
        
        let stringSession = KeychainService.instance.secureGet(forKey: "SESSION")
        if let session = stringSession {
            let user = try? JSONDecoder().decode(User.self, from: session.data(using: .utf8)!)
            self.currentSession = user;
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Group {
                    if isMe {
                        PhotosPicker(selection: $selection, preferredItemEncoding: .automatic) {
                            ProfileImageView(
                                imageData: selectedImageData,
                                imageUrl: viewModel.profile?.profile_picture
                            )
                        }
                        .onChange(of: selection) { oldValue, newValue in
                            guard let newValue = newValue else { return }
                            Task {
                                if let imageData = try? await newValue.loadTransferable(type: Data.self) {
                                    self.selectedImageData = UIImage(data: imageData)
                                    self.isCropperPresented.toggle()
                                }
                            }
                        }
                    } else {
                        ProfileImageView(
                            imageData: nil,
                            imageUrl: viewModel.profile?.profile_picture
                        )
                    }
                }
                
                Spacer()
                VStack(alignment: .leading) {
                    Text("\(viewModel.profile?.first_name ?? "") \(viewModel.profile?.last_name ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !self.isMe, currentSession?.username != viewModel.profile?.username, let profile = viewModel.profile {
                        FollowButton(profile: profile) {
                            // 🔁 Force refresh the layout or set a flag
                            withAnimation {
                                viewModel.objectWillChange.send()
                            }
                        }
                    }

                }
                Spacer()
            }
            HStack {
                
                Button(action: {
                    viewModel.getFollowers(status: FollowStatus.ACCEPTED)
                    self.selectedSegment = "followers"
                    showFollows.toggle()
                }) {
                    VStack {
                        Text("Followers")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(viewModel.profile?.followers_count ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.text)
                    }
                }
                
                Spacer()
                Button(action: {
                    viewModel.getFollowings(status: FollowStatus.ACCEPTED)
                    self.selectedSegment = "followings"
                    showFollows.toggle()
                }) {
                    VStack {
                        Text("Followings")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(viewModel.profile?.followings_count ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.text)
                    }
                }
            }
            .padding(.top, 20)
            .sheet(isPresented: $isCropperPresented) {
                CircularCropView(image: $selectedImageData)
            }
            .sheet(isPresented: $showFollows) {
                FollowsSheet(selectedSegment: $selectedSegment, selectedUser: $selectedUser)
            }
            .navigationDestination(item: $selectedUser) { user in
                ProfileView(username: user)
            }
        }.padding(.horizontal, 20)
    }

}

#Preview {
    Main()
}

