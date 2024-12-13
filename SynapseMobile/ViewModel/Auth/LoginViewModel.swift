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
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(handle401), name: .didReceive401, object: nil)
    }
    
   deinit {
       NotificationCenter.default.removeObserver(self, name: .didReceive401, object: nil)
   }
    
    @objc private func handle401() {
        let stringSession = KeychainService.instance.secureGet(forKey: "SESSION")
        if let session = stringSession {
            do {
                let user = try JSONDecoder().decode(User.self, from: session.data(using: .utf8)!)
                
                FetchService().executeRequest(url: "/auth/refresh",
                                              method: "PUT",
                                              data: ["refresh_token": user.refresh_token]
                ) { data, response, error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    }
                    
                    if let data = data {
                        do {
                            let user = try JSONDecoder().decode(User.self, from: data)
                            // Save the user to the keychain
                            do {
                                try KeychainService.instance.secureStore(user, forKey: "SESSION")
                                DispatchQueue.main.async {
                                    self.user = user
                                    self.isLogged = true
                                }
                                print("Token refreshed")
                            } catch {
                                self.errorMessage = "Failed to save user to keychain."
                                self.isLogged = false
                            }
                        } catch {
                            self.errorMessage = "Invalid username or password."
                            self.isLogged = false
                        }
                    }
                }
            } catch {
                self.isLogged = false
                print("Failed to clear token")
            }
        }
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
                    // Save the user to the keychain
                    do {
                        try KeychainService.instance.secureStore(user, forKey: "SESSION")
                        DispatchQueue.main.async {
                            self.user = user
                            self.isLogged = true
                        }
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
        
            let stringSession = KeychainService.instance.secureGet(forKey: "SESSION")
            if let session = stringSession {
                let user = try? JSONDecoder().decode(User.self, from: session.data(using: .utf8)!)
                if let tokenExpiresAt = user?.refresh_expires_at {
                    DispatchQueue.main.async {
                        if Date().isTokenValid(expiresAt: tokenExpiresAt)
                        {
                            self.isLogged = true;
                        }
                        else {
                            self.isLogged = false;
                        }
                    }
                }
            } else {
                self.isLogged = false;
            }
    }
}

