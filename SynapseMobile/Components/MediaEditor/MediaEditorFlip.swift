//
//  MediaEditorFooter.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 13.11.2024.
//

import SwiftUI
import Foundation

struct MediaEditorFlip : View {
    @Binding var image: UIImage?
    @Binding var rotation: Double
    
    var body: some View {
        Slider(value: $rotation, in: 0...360, step: 1) {
            
            Image(systemName: "rotate.left")
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .padding()

        Button(action: {
            // Rotate right
            self.rotation += 90
        }) {
            Image(systemName: "rotate.right")
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .padding()

        Button(action: {
            self.image = self.image?.withHorizontallyFlippedOrientation()
        }){
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
    }
}
