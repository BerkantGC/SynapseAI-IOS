//
//  UserSearchCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 24.11.2024.
//

import SwiftUI

struct UserSearchCard: View {
    var user: UserSearchModel
    var body: some View {
        HStack{
            if user.profile_picture != nil {
                let pp_url = user.profile_picture!
                AsyncImage(url: URL(string: pp_url)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                } placeholder: {
                    Image("placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            VStack(alignment: .leading){
                Text(user.username)
                    .font(.headline)
                Text(user.fullname ?? "")
                    .font(.subheadline)
            }
        }
    }
}
