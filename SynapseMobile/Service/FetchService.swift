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
    
    func buildUrl(url: String,
                  method: String?,
                  data: [String: Any]?) -> URLRequest
    {
        var url = url
        
        if !url.starts(with: "http://"){
            url = "http://localhost:8080" + url
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method ?? "GET"
        
        let session = KeychainService.instance.secureGet(forKey: "user");
        if let session = try? JSONDecoder().decode(User.self, from: Data(session!.utf8))
        {
            !url.starts(with: "http://localhost:8080/auth") ?
            request.setValue("Bearer \(session.token ?? "")", forHTTPHeaderField:  "Authorization") : nil
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
    
    func executeRequest(url: String, method: String?, data: [String: Any]?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = buildUrl(url: url, method: method, data: data)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        self.viewModel.isLogged = false
                    }
                }
            }
            
            completion(data, response, error)
        }
        task.resume()
    }
}
