//
//  ProfileHeader.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

struct ProfileHeader : View {
    @EnvironmentObject var viewModel: ProfileViewModel;
    var profile: ProfileModel;
    @State var showFollows = false
    @State var selectedSegment: String = "followers"
    @State var isNavigatingProfile = false
    
    init(profile: ProfileModel) {
        self.profile = profile
    }
    
    var body: some View {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: "http://localhost:8080/image/\(profile.profile_picture ?? "").png")!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .shadow(radius: 10)
                    } placeholder: {
                        Image("placeholder")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .shadow(radius: 10)
                    }.frame(width: 100, height: 100)
                    VStack(alignment: .leading) {
                        Text(profile.first_name! + " " + profile.last_name!)
                            .font(.title)
                            .fontWeight(.bold)
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
                            Text("Takipçiler")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(profile.followers_count)")
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
                            Text("Takip Edilenler")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(profile.followings_count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.text)
                        }
                    }
                }
                .padding(.top, 20)
                .sheet(isPresented: $showFollows) {
                    FollowsSheet(selectedSegment: $selectedSegment, isNavigatingProfile: $isNavigatingProfile)
                }
                .navigationDestination(isPresented: self.$isNavigatingProfile) {
                    ProfileView(username: profile.username)
                }
            }.padding(.horizontal, 20)
        
    }
}
 
#Preview {
    MyProfileView()
}
