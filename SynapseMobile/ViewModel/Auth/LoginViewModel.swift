// LoginViewModel.swift

import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLogged: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(handle401), name: .didReceive401, object: nil)
    }
    
    @objc private func handle401() {
           isLogged = false
           print("User logged out due to 401 Unauthorized")
           // Perform any additional logout actions here
       }
       
       deinit {
           NotificationCenter.default.removeObserver(self, name: .didReceive401, object: nil)
       }
    
    func login() {
        // Simulate a login request
        guard !self.username.isEmpty, !self.password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        
        
        FetchService().executeRequest(url: "/auth/login",
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
                    
                    // Save the user to the keychain
                    do {
                        try KeychainService.instance.secureStore(user, forKey: "user")
                    } catch {
                        self.errorMessage = "Failed to save user to keychain."
                    }
                } catch {
                    self.errorMessage = "Invalid username or password."
                }
            }
        }
    }
        
    func checkToken(){
        DispatchQueue.main.async {
            let stringSession = KeychainService.instance.secureGet(forKey: "user")
            if let session = stringSession {
                let user = try? JSONDecoder().decode(User.self, from: session.data(using: .utf8)!)
                let tokenExpiresAt = user?.expires_at
                if Date().isTokenValid(expiresAt: tokenExpiresAt!)
                {
                    self.isLogged = true;
                }
                else {
                    self.isLogged = false;
                }
            } else {
                self.isLogged = false;
            }
        }
    }
}

