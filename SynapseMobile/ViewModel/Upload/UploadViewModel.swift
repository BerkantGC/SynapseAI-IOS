//
//  UploadViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/5/24.
//

import Foundation
import _PhotosUI_SwiftUI
import SwiftUICore

class UploadViewModel: ObservableObject {
    @Published var isSelected = false
    @Published var selectedImageData: Data?
    @Published var selection: PhotosPickerItem?
    @Published var isShowingImageGenerator = false
    
    static let shared = UploadViewModel()
    
    func navigateImageGenerator() {
        isShowingImageGenerator = true
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        //
        return .animal
    }
}
