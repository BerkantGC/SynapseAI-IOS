//
//  UserSearchCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 24.11.2024.
//

import SwiftUI
import Kingfisher

struct UserSearchCard: View {
    var user: UserSearchModel
    var body: some View {
        HStack (spacing: 15){
            ProfileImageView(imageData: nil, imageUrl: user.profile_picture, size: 50)
            VStack(alignment: .leading){
                Text(user.username)
                    .font(.headline)
                Text(user.fullname ?? "")
                    .font(.subheadline)
            }
            Spacer()
        }.padding(.horizontal)
        
    }
}
