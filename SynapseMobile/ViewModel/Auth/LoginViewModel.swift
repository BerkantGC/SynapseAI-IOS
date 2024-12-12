// LoginViewModel.swift

import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @AppStorage("isLogged") var isLogged: Bool = false
    @Published var loading: Bool = false
    
    static let shared = LoginViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(handle401), name: .didReceive401, object: nil)
    }
    
   deinit {
       NotificationCenter.default.removeObserver(self, name: .didReceive401, object: nil)
   }
    
    @objc private func handle401() {
           isLogged = false
           print("User logged out due to 401 Unauthorized")
           // Perform any additional logout actions here
   }
    
    func login() {
        // Simulate a login request
        guard !self.username.isEmpty, !self.password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        loading = true
        
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
                        try KeychainService.instance.secureStore(user, forKey: "SESSION")
                    } catch {
                        self.errorMessage = "Failed to save user to keychain."
                    }
                } catch {
                    self.errorMessage = "Invalid username or password."
                }
                
                self.loading = false
            }
        }
    }
        
    func checkToken(){
        DispatchQueue.main.async {
            let stringSession = KeychainService.instance.secureGet(forKey: "SESSION")
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

