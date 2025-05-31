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
        HStack (spacing: 15){
            if user.profile_picture != nil {
                let pp_url = user.profile_picture!
                AsyncImage(url: URL(string: pp_url)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .shadow(radius: 10)
                } placeholder: {
                    Image("placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }.frame(width: 50, height: 50)
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
            Spacer()
        }.padding(.horizontal)
        
    }
}
