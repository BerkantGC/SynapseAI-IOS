//
//  UserCommentCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 18.11.2024.
//

import Foundation
import SwiftUI

struct UserCommentCard: View {
    var comment: CommentModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info Row
            HStack(alignment: .top, spacing: 12) {
                ProfileImageView(imageData: nil, imageUrl: comment.profile_picture, size: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(comment.user)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(comment.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button(action: {
                    // options
                }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.secondary)
                }
            }
            
            // Actions Row
            HStack(spacing: 16) {
                Button {
                    print("Like")
                } label: {
                    Label("Like", systemImage: "heart")
                        .labelStyle(IconOnlyLabelStyle())
                }
                
                Button {
                    print("Reply")
                } label: {
                    Label("Reply", systemImage: "bubble.left")
                        .labelStyle(IconOnlyLabelStyle())
                }
                
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
