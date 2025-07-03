//
//  fetchService.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation
import SwiftUICore

class FetchService{
    @EnvironmentObject var viewModel: LoginViewModel
    @EnvironmentKey("BASE_URL")
    var baseUrl: String
    
    func buildUrl(url: String,
                  method: String?,
                  data: [String: Any]?) -> URLRequest
    {
        var url = url
        
        if !url.starts(with: "http://"){
            url = baseUrl  + url
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method ?? "GET"
        
        if let session = KeychainService.instance.secureGet(forKey: "SESSION"){
            if let session = try? JSONDecoder().decode(User.self, from: Data(session.utf8))
            {
                !url.starts(with: "\(baseUrl)/auth") ?
                request.setValue("Bearer \(session.token)", forHTTPHeaderField:  "Authorization") : nil
            }
        }
        
        if data == nil {
            return request;
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyData = try? JSONSerialization.data(
            withJSONObject: data as Any,
            options: []
        )
        request.httpBody = bodyData
        
        return request;
    }
    
    func buildFormData(url: String,
                       method: String = "POST",
                       data: [String: Any],
                       fileKey: String? = nil,
                       fileData: Data? = nil,
                       fileName: String = "file",
                       mimeType: String = "image/jpeg",
                       completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        var url = url
        if !url.starts(with: "http://") {
            url = baseUrl + url
        }
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = method
        
        // Generate boundary string
        let boundary = UUID().uuidString
        
        // Set Content-Type Header for multipart/form-data
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization Header
        let session = KeychainService.instance.secureGet(forKey: "SESSION")
        if let session = try? JSONDecoder().decode(User.self, from: Data(session!.utf8)) {
            if !url.starts(with: "\(baseUrl)/auth") {
                urlRequest.setValue("Bearer \(session.token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        // Build multipart body
        var formData = Data()
        
        // Add text fields
        for (key, value) in data {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            formData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add file data if provided
        if let fileKey = fileKey, let fileData = fileData {
            formData.append("--\(boundary)\r\n".data(using: .utf8)!)
            formData.append("Content-Disposition: form-data; name=\"\(fileKey)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            formData.append(fileData)
            formData.append("\r\n".data(using: .utf8)!)
        }
        
        // Close boundary
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Upload the data
        URLSession.shared.uploadTask(with: urlRequest, from: formData) { data, response, error in
            self.handleResponse(data: data, response: response, error: error)
            
            completion(data, response, error)
        }.resume()
    }

    func executeRequest(url: String, method: String?, data: [String: Any]?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = buildUrl(url: url, method: method, data: data)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error)
            
            completion(data, response, error)
        }
        task.resume()
    }
    
    // Updated method to handle all responses
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        // Handle network errors first
        if let error = error {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .didReceiveError,
                    object: nil,
                    userInfo: ["message": "Network error: \(error.localizedDescription)"]
                )
            }
            return
        }
        
        // Handle HTTP response codes
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299, 400, 403:
                // Success - do nothing
                break
            case 401:
                // Unauthorized - existing behavior
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .didReceive401, object: nil)
                }
            default:
                if let data = data {
                    print("Raw data length: \(data.count)")
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Raw data as string: \(dataString)")
                    } else {
                        print("Data cannot be converted to UTF-8 string")
                    }
                } else {
                    print("Data is nil")
                }
                
                var message: String
                
                // Check if data exists and is not empty
                guard let data = data, !data.isEmpty else {
                    print("Data is nil or empty, using default error message")
                    message = getErrorMessage(for: httpResponse.statusCode)
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: .didReceiveError,
                            object: nil,
                            userInfo: ["message": message]
                        )
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    message = errorResponse.message
                    print("Successfully decoded error response: \(message)")
                } catch {
                    print("JSON decoding error: \(error)")
                    
                    // Try to get a string representation of the data
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Failed to decode JSON, raw response: \(dataString)")
                    }
                    
                    // Fallback to default error message
                    message = getErrorMessage(for: httpResponse.statusCode)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .didReceiveError,
                        object: nil,
                        userInfo: ["message": message]
                    )
                }
            }
        }
    }
    
    // Helper method to get appropriate error messages for different status codes
    private func getErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 404:
            return "Resource not found."
        case 422:
            return "Invalid data provided."
        case 500:
            return "Server error. Please try again later."
        case 502:
            return "Bad gateway. Server is temporarily unavailable."
        case 503:
            return "Service unavailable. Please try again later."
        default:
            return "Request failed with status code \(statusCode)."
        }
    }
    
    // Keep the old method for backward compatibility
    func handleUnauthorizedResponse(response: URLResponse?) {
        handleResponse(data: nil, response: response, error: nil)
    }
}
