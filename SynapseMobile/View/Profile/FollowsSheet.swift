//
//  FollowsSheet.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 13.11.2024.
//

import Foundation
import SwiftUI

struct FollowsSheet : View {
    @Binding var selectedSegment: String;
    @Binding var selectedUser: String?;
    @EnvironmentObject var viewModel: ProfileViewModel;
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Background()
            VStack{
                Picker(selection: $selectedSegment, label: Text("Picker")) {
                    Text("Takipçiler")
                        .tag("followers")
                    
                    Text("Takip Edilenler")
                        .tag("followings")
                }.onChange(of: selectedSegment, {
                    if selectedSegment == "followers" {
                        viewModel.getFollowers(status: FollowStatus.ACCEPTED)
                    } else {
                        viewModel.getFollowings(status: FollowStatus.ACCEPTED)
                    }
                })
                    .pickerStyle(.segmented)
                .pickerStyle(.segmented)
                .padding()
                
                if selectedSegment == "followers" {
                    if viewModel.followers.isEmpty {
                        Text("Takipçi Bulunamadı")
                    }else{
                        ForEach(viewModel.followers) { follower in
                            UserFollowCard(follow: follower)
                                .onTapGesture {
                                    selectedUser=follower.username
                                    dismiss()
                                }
                        }
                    }
                } else {
                    if viewModel.followings.isEmpty {
                        Text("Takipçi Bulunamadı")
                    }else{
                        ForEach(viewModel.followings) { follower in
                            UserFollowCard(follow: follower)
                                .onTapGesture {
                                    selectedUser=follower.username
                                    dismiss()
                                }
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}
