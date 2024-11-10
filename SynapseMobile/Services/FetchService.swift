//
//  fetchService.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation

class FetchService{
    
    func buildUrl(url: String, method: String?, data: [String: Any]?) -> URLRequest{
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method ?? "GET"
        
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
            completion(data, response, error)
        }
        task.resume()
    }
}
