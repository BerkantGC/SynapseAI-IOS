// LoginViewModel.swift

import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    var user: User? = nil
    @Published var errorMessage: String? = nil
    @Published var isLogged: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func login(username: String, password: String) {
        // Simulate a login request
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        
        
        FetchService().executeRequest(url: "http://localhost:8080/auth/login",
                                      method: "POST",
                                      data: ["username": username, "password": password]
        ) { data, response, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
            
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self.user = user
                    self.isLogged = true
                    print("User: \(user)")
                } catch {
                    self.errorMessage = "Invalid username or password."
                }
            }
        }
    }
}

