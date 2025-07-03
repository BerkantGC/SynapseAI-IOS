//
//  EnhanceModalViewModel.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 21.06.2025.
//

import Foundation

private struct ApiResponse: Codable {
    let image_url: String
}

@MainActor
class EnhanceModalViewModel: ObservableObject {
    @Published var enhancedPrompt: String = ""
    @Published var newImageUrl: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func enhanceImage(postID: Int, imageURL: String) async {
        guard !enhancedPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter an enhanced prompt"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            await FetchService().executeRequest(
                url: "/posts/\(postID)/enhance",
                method: "POST",
                data: ["prompt": enhancedPrompt]
            ) { [weak self] data, response, error in
                
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let data = data else {
                        self.errorMessage = "No data received from server"
                        return
                    }
                    do {
                        // Print the raw data as a string to see what you're receiving
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Raw JSON response:")
                            print(jsonString)
                        } else {
                            print("Could not convert data to string")
                        }
                        
                        let response = try JSONDecoder().decode(ApiResponse.self, from: data)
                        self.newImageUrl = response.image_url
                        self.errorMessage = nil
                    } catch {
                        self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                        
                        // Print detailed decoding error
                        if let decodingError = error as? DecodingError {
                            print("Decoding error details:")
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("Key '\(key)' not found: \(context.debugDescription)")
                            case .typeMismatch(let type, let context):
                                print("Type '\(type)' mismatch: \(context.debugDescription)")
                            case .valueNotFound(let value, let context):
                                print("Value '\(value)' not found: \(context.debugDescription)")
                            case .dataCorrupted(let context):
                                print("Data corrupted: \(context.debugDescription)")
                            @unknown default:
                                print("Unknown decoding error: \(error)")
                            }
                        }
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to encode request: \(error.localizedDescription)"
        }
    }
    
    func replaceImage(postID: Int) async {
        guard let newImageUrl = newImageUrl else {
            errorMessage = "No enhanced image available"
            return
        }
        
        guard !enhancedPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enhanced prompt is required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            await FetchService().executeRequest(
                url: "/posts/\(postID)/replace-image",
                method: "PUT",
                data: ["prompt": enhancedPrompt, "new_image_url": newImageUrl]
            ) { [weak self] data, response, error in
                
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Failed to replace image: \(error.localizedDescription)"
                        return
                    }
                    
                    // Check HTTP status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                            // Success - you might want to add a success callback here
                            self.errorMessage = nil
                        } else {
                            self.errorMessage = "Server error: \(httpResponse.statusCode)"
                        }
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to encode request: \(error.localizedDescription)"
        }
    }
    
    func resetState() {
        enhancedPrompt = ""
        newImageUrl = nil
        isLoading = false
        errorMessage = nil
    }
}
