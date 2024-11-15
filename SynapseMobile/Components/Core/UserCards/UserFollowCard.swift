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
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "http://localhost:8080/image/\(follow.profile_picture ?? "").png")!) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .shadow(radius: 10)
            } placeholder: {
                Image("placeholder")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .shadow(radius: 10)
            }.frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(follow.fullname!)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(follow.username)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                print("Takip ediliyor")
            }) {
                Text("Takip Ediliyor")
                    .font(.subheadline)
                    .foregroundColor(.text)
                    .padding()
                    .background(Color.loginBG)
                    .cornerRadius(10)
            }
        }.padding()
    }
}
