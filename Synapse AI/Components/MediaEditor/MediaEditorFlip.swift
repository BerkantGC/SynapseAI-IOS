//
//  MediaEditorFooter.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 13.11.2024.
//

import Foundation
import SwiftUI

import SwiftUI

struct MediaEditorFlip: View {
    @Binding var image: UIImage?
    @Binding var rotation: Double

    var body: some View {
        HStack {
            Slider(value: $rotation, in: 0...360, step: 1) {
                Text("Rotation")
            }
            .padding()

            Button(action: {
                self.rotation += 90
            }) {
                Image(systemName: "rotate.right")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .padding()

            Button(action: {
                self.image = self.image?.withHorizontallyFlippedOrientation()
            }) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}
