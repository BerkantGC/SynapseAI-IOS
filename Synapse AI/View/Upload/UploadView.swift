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
        NavigationStack{
            ZStack{
            Background()
                VStack{
                Spacer()
                
                    HStack(spacing: 30){
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        PhotosPicker(
                            selection: $viewModel.selection,
                            matching: .any(of: [.images, .videos]),
                            preferredItemEncoding: .automatic
                        ){
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
                            guard let selection = viewModel.selection else { return }

                            Task {
                                // Check supported content types first
                                let supportedTypes = selection.supportedContentTypes
                                
                                if supportedTypes.contains(where: { $0.conforms(to: .movie) }) {
                                    if let video = try? await selection.loadTransferable(type: VideoTransferable.self) {
                                        viewModel.selectedVideoURL = video.url
                                        viewModel.selectedImageData = nil
                                        viewModel.isSelected = true
                                    }
                                } else if supportedTypes.contains(where: { $0.conforms(to: .image) }) {
                                    if let image = try? await selection.loadTransferable(type: Data.self) {
                                        viewModel.selectedImageData = image
                                        viewModel.selectedVideoURL = nil
                                        viewModel.isSelected = true
                                    }
                                } else {
                                    print("Unsupported type: \(supportedTypes)")
                                }
                            }
                        }
                        .navigationDestination(isPresented: $viewModel.isSelected){
                            if let imageData = viewModel.selectedImageData {
                                PostUploadView(image: imageData)
                            } else if let videoURL = viewModel.selectedVideoURL {
                                UploadFormPage(media: .video(videoURL))
                            }
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

// Custom transferable type for videos
struct VideoTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "video.mov")
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}

#Preview {
    Main()
}
