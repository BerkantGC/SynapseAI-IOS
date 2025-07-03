//
//  FullScreenImageView.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 21.06.2025.
//

import SwiftUI
import Kingfisher

struct FullScreenImageModifier: ViewModifier {
    let imageUrl: URL
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    KFImage(imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            isPresented = false
                        }
                }
            }
    }
}

extension View {
    func fullScreenOnTap(imageUrl: URL) -> some View {
        self.modifier(FullScreenImageModifier(imageUrl: imageUrl))
    }
}
