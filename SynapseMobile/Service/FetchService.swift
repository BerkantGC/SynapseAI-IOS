//
//  fetchService.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation
import SwiftUICore

class FetchService {
    @EnvironmentObject var viewModel: LoginViewModel
    @EnvironmentKey("BASE_URL")
    var baseUrl: String

    private let cache = NSCache<NSString, CachedResponse>()

        class CachedResponse: NSObject {
            let data: Data
            let response: URLResponse
            let timestamp: Date

            init(data: Data, response: URLResponse, timestamp: Date) {
                self.data = data
                self.response = response
                self.timestamp = timestamp
            }
        }

        private func getCachedResponse(for request: URLRequest, cacheDuration: TimeInterval) -> CachedResponse? {
            guard let url = request.url else { return nil }
            
            if let cachedResponse = cache.object(forKey: url.absoluteString as NSString) {
                if Date().timeIntervalSince(cachedResponse.timestamp) < cacheDuration {
                    return cachedResponse
                } else {
                    cache.removeObject(forKey: url.absoluteString as NSString)
                }
            }
            return nil
        }

        private func cacheResponse(data: Data, response: URLResponse, for request: URLRequest) {
            guard let url = request.url else { return }
            let cachedResponse = CachedResponse(data: data, response: response, timestamp: Date())
            cache.setObject(cachedResponse, forKey: url.absoluteString as NSString)
        }


    func buildUrl(url: String, method: String?, data: [String: Any]?) -> URLRequest {
        var url = url

        if !url.starts(with: "http://") {
            url = baseUrl + url
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method ?? "GET"

        if let session = KeychainService.instance.secureGet(forKey: "SESSION") {
            if let session = try? JSONDecoder().decode(User.self, from: Data(session.utf8)) {
                !url.starts(with: "\(baseUrl)/auth") ?
                request.setValue("Bearer \(session.token ?? "")", forHTTPHeaderField: "Authorization") : nil
            }
        }

        if data == nil {
            return request
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyData = try? JSONSerialization.data(
            withJSONObject: data as Any,
            options: []
        )
        request.httpBody = bodyData

        return request
    }

    func executeRequest(url: String, method: String?, data: [String: Any]?, useCache: Bool = true, cacheDuration: TimeInterval = 60, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = buildUrl(url: url, method: method, data: data)

        // Check cache
        if useCache, method == nil || method == "GET" {
            if let cachedResponse = getCachedResponse(for: request, cacheDuration: cacheDuration) {
                completion(cachedResponse.data, cachedResponse.response, nil)
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.handleUnauthorizedResponse(response: response)

            if let data = data, let response = response {
                self?.cacheResponse(data: data, response: response, for: request)
            }

            completion(data, response, error)
        }
        task.resume()
    }

    func buildFormData(url: String, method: String = "POST", data: [String: Any], fileKey: String? = nil, fileData: Data? = nil, fileName: String = "file", mimeType: String = "image/jpeg", completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

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
                urlRequest.setValue("Bearer \(session.token ?? "")", forHTTPHeaderField: "Authorization")
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
            self.handleUnauthorizedResponse(response: response)

            completion(data, response, error)
        }.resume()
    }

    func handleUnauthorizedResponse(response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didReceive401, object: nil)
            }
        }
    }
}
