//
//  UserCommentCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 18.11.2024.
//

import Foundation
import SwiftUI

struct UserCommentCard : View {
    var comment: CommentModel
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: comment.profile_picture ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                } placeholder: {
                    ProgressView()
                }
                VStack(alignment: .leading) {
                    Text(comment.user)
                        .font(.headline)
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .padding()
            }.padding()
            Text(comment.content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            HStack {
                Button(action: {
                    print("Beğen")
                }) {
                    Image(systemName: "heart")
                }
                Button(action: {
                    print("Yorum Yap")
                }) {
                    Image(systemName: "message")
                }
                Spacer()
            }.padding()
        }
    }
}
