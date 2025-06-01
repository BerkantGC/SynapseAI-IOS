//
//  UserFollowCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 13.11.2024.
//

import Foundation
import SwiftUI

struct UserFollowCard : View {
    var follow: FollowModel
    var isFollower: Bool;
    
    init(follow: FollowModel, isFollower: Bool = false) {
        self.follow = follow
        self.isFollower = isFollower
    }
    
    var body: some View {
        HStack {
            ProfileImageView(imageData: nil, imageUrl: follow.profile_picture, size: 50)
            VStack(alignment: .leading) {
                Text(follow.fullname!)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(follow.username)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            if !isFollower {
                Button(action: {
                    print("Following")
                }) {
                    Text("Following")
                        .font(.subheadline)
                        .foregroundColor(.text)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Color.loginBG)
                        .cornerRadius(10)
                }
            }
        }.padding()
    }
}
