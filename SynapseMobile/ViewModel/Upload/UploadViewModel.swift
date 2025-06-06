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
    @Published var errorMessage: String?
    @Published var selectedImageData: Data?
    @Published var selection: PhotosPickerItem?
    @Published var isShowingImageGenerator = false
    
    static let shared = UploadViewModel()
    
    func navigateImageGenerator() {
        isShowingImageGenerator = true
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            Task { // hop into an actor-isolated context (likely MainActor)
                await MainActor.run {
                    FetchService().executeRequest(
                        url: "/image/generate",
                        method: "POST",
                        data: ["prompt": prompt]
                    ) { data, response, error in

                        if let error = error {
                            print("Request failed: \(error.localizedDescription)")
                            continuation.resume(returning: nil)
                            return
                        }

                        guard let data = data else {
                            continuation.resume(returning: nil)
                            return
                        }

                        do {
                            let generateResponse = try JSONDecoder().decode(GenerateResponse.self, from: data)
                            var base64String = generateResponse.image

                            // Remove base64 prefix if exists
                            if let commaIndex = base64String.firstIndex(of: ",") {
                                base64String = String(base64String[base64String.index(after: commaIndex)...])
                            }

                            if let imageData = Data(base64Encoded: base64String),
                               let image = UIImage(data: imageData) {
                                continuation.resume(returning: image)
                            } else {
                                continuation.resume(returning: nil)
                            }

                        } catch {
                            print("Decoding error: \(error.localizedDescription)")
                            continuation.resume(returning: nil)
                        }
                    }
                }
            }
        }
    }
    
    func generateVideo(prompt: String) async -> String? {
        await withCheckedContinuation { continuation in
            Task {
                await MainActor.run {
                    FetchService().executeRequest(
                        url: "/videos/generate",
                        method: "POST",
                        data: [
                            "prompt": prompt,
                            "aspect_ratio": "9:16",
                            "person_generation": false
                        ]
                    ) { data, response, error in
                        
                        if let error = error {
                            print("Request failed: \(error.localizedDescription)")
                            continuation.resume(returning: nil)
                        }

                        let httpResponse = response as? HTTPURLResponse
                        guard let data = data,
                              httpResponse!.statusCode == 200 else {
                            print("Invalid response or no data", httpResponse?.statusCode)
                            continuation.resume(returning: nil)
                            return
                        }
                      
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("generated_video.mp4")
                        
                        do {
                            self.deleteTempFileIfExists(at: tempURL.path)
                            try data.write(to: tempURL)
                            print("Video saved to:", tempURL)
                            continuation.resume(returning: tempURL.path)
                        } catch {
                            print("Failed to save video:", error.localizedDescription)
                            continuation.resume(returning: nil)
                        }
                    }
                }
            }
        }
    }
    
    func deleteTempFileIfExists(at path: String) {
        let fileURL = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
            print("Deleted temp file at:", fileURL)
        }
    }

}
