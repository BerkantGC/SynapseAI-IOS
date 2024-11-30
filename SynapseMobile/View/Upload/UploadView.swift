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
    @State var isSelected = false
    @State var selectedImageData: Data?
    @State var selection: PhotosPickerItem?
    
    var body: some View{
        ZStack{
            Background()
            NavigationStack{
                VStack{
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        PhotosPicker(selection: $selection, preferredItemEncoding: .automatic){
                            Text("foto")
                        }.onChange(of: selection) {
                            if let selection = selection {
                                Task{
                                    if let image = try await selection.loadTransferable(type: Data.self){
                                        self.selectedImageData = image
                                        self.isSelected = true
                                    }
                                }
                            }
                        }.navigationDestination(isPresented: $isSelected){
                            PostUploadView(image: selectedImageData)
                        }
                    }
                }
            }
        }
    }
}
