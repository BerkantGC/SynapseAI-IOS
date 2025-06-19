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
                Rectangle()
                    .fill(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
                
                if let img = image {
                       Image(uiImage: img)
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
                           .cornerRadius(10)
                           .clipped()
                           .rotationEffect(.degrees(rotation.truncatingRemainder(dividingBy: 361)))
                           .animation(.easeInOut, value: rotation)
               }

            }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)


            Spacer()

            HStack {
                if selectedEditing != nil {
                    Button(action: {
                        self.selectedEditing = nil
                    }) {
                        Image(systemName: "arrowshape.backward.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding()
                }

                Spacer()

                switch selectedEditing {
                case "flip":
                    MediaEditorFlip(image: $image, rotation: $rotation)
                case "filter":
                    MediaEditorFilter(image: $image)
                default:
                    HStack {
                        Button(action: {
                            self.selectedEditing = "flip"
                        }) {
                            Image(systemName: "righttriangle.split.diagonal")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .padding()

                        Button(action: {
                            self.selectedEditing = "filter"
                        }) {
                            Image(systemName: "camera.filters")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }

                Spacer()
            }
        }
        .padding()
        .navigationBarTitle("Media Editor", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if image != nil {
                    NavigationLink(destination: UploadFormPage(media: .image(image!))) {
                        Text("Share")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.blue))
                    }
                }
            }
        }
    }
}
