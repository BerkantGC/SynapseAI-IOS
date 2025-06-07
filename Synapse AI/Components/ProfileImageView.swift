//
//  ProfileImageSmall.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

import SwiftUI
import Kingfisher

struct ProfileImageView: View {
    let imageData: UIImage?
    let imageUrl: String?
    var size: CGFloat = 100 // Default size

    var body: some View {
        ZStack {
            if let image = imageData {
                Image(uiImage: image)
                    .resizable()
            } else if let imageUrl = imageUrl,
                      let url = URL(string: imageUrl) {
                KFImage(url)
                    .placeholder {
                        Image("placeholder")
                            .resizable()
                    }
                    .resizable()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 1))
        .shadow(radius: 5)
    }
}
