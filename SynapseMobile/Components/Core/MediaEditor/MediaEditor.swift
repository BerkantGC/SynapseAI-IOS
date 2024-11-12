//
//  MediaEditor.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

struct MediaEditor: View {
    @State var selectedEditing: String? = nil
    @State var image: UIImage?
    @State var rotation: Double = 0
   
    init(image: UIImage? = nil) {
        self._image = State(initialValue: image)
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Dark grey background for placeholder
                Rectangle()
                    .fill(Color(.systemGray6)) // Dark grey color
                    .frame(width: .infinity, height: UIScreen.main.bounds.height / 2)
                    .cornerRadius(10)
                
                // Show image if available, otherwise dark grey rectangle remains
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: .infinity, height: UIScreen.main.bounds.height / 2)
                        .cornerRadius(10)
                        .clipped()
                        .rotationEffect(.degrees(rotation))
                        .animation(.smooth, value: rotation)
                }
            }
            Spacer()
            
            HStack {
                if selectedEditing != nil {
                    Button(action: {
                        // reset selectedEditing
                        self.selectedEditing = nil
                    }) {
                        Image(systemName: "arrowshape.backward.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                switch selectedEditing {
                case "flip":
                    MediaEditorFlip(image: $image, rotation: $rotation)
                case "filter":
                    MediaEditorFilter(image: $image)
                default:
                    Button(action: {
                        // Flip
                        self.selectedEditing = "flip"
                    }) {
                        Image(systemName: "righttriangle.split.diagonal")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding()
                    Button(action: {
                        // Filter
                        self.selectedEditing = "filter"
                    }) {
                        Image(systemName: "camera.filters")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .navigationBarTitle("Medya Düzenleyici", displayMode: .inline)
    }
}
