//
//  ImageGeneratorView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/5/24.
//

import Foundation
import SwiftUI

struct ImageGeneratorView: View {
    @ObservedObject var viewModel = UploadViewModel.shared // Ensure this is an @ObservedObject for bindings
    
    @State var prompt = ""
    @State var image: UIImage?
    
    var body: some View {
        ZStack {
            Background()
            
            VStack {
                ZStack {
                    // Dark grey background for placeholder
                    Rectangle()
                        .fill(Color(.systemGray6)) // Dark grey color
                        .frame(width: .infinity, height: UIScreen.main.bounds.height / 2)
                        .cornerRadius(10)
                        .overlay(
                            Text("Preview")
                                .bold()
                                .font(.title)
                        )
                    
                    // Show image if available, otherwise dark grey rectangle remains
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: .infinity, height: UIScreen.main.bounds.height / 2)
                            .cornerRadius(10)
                            .clipped()
                    }
                }.padding(.horizontal)
                
                TextField("Enter prompt..", text: $prompt, axis: .vertical)
                    .lineLimit(5)
                    .frame(maxHeight: UIScreen.main.bounds.height/6) // Adjust height for multi-line input
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(radius: 5)
                Button("Generate") {
                    Task {
                        if let img = await viewModel.generateImage(prompt: prompt) {
                            image = img
                        }
                    }
                }
            }
        }
        .navigationTitle("Generate")
        .toolbar {
            // Hack: To show back title for navigation bar
            ToolbarItem(placement: .primaryAction) {
                Button { } label: {
                    Color.clear
                }
            }
        }
    }
}
