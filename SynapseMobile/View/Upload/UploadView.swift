//
//  UploadView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct UploadView: View {
    @StateObject var viewModel = UploadViewModel.shared
    
    var body: some View{
        ZStack{
            Background()
            NavigationStack{
                VStack{
                Spacer()
                
                    HStack(spacing: 30){
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        PhotosPicker(selection: $viewModel.selection, preferredItemEncoding: .automatic){
                            VStack{
                                Image(systemName: "photo.stack")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70)
                                    .foregroundColor(.text)
                                Text("Upload")
                                    .font(.title2)
                                    .foregroundColor(.text)
                                    .padding()
                            }
                            
                        }.onChange(of: viewModel.selection) {
                            if let selection = viewModel.selection {
                                Task{
                                    if let image = try await selection.loadTransferable(type: Data.self){
                                        viewModel.selectedImageData = image
                                        viewModel.isSelected = true
                                    }
                                }
                            }
                        }.navigationDestination(isPresented: $viewModel.isSelected){
                            PostUploadView(image: viewModel.selectedImageData)
                        }
                    }
                    
                    VStack{
                        Image(systemName: "apple.image.playground")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70)
                            .foregroundColor(.text)
                        Text("Generate")
                            .font(.title2)
                            .foregroundColor(.text)
                            .padding()
                    }.onTapGesture {
                        viewModel.navigateImageGenerator()
                    }.navigationDestination(isPresented: $viewModel.isShowingImageGenerator){
                        ImageGeneratorView()
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                }
                
                Spacer()
                }
            }
        }
    }
}

#Preview {
    Main()
}
