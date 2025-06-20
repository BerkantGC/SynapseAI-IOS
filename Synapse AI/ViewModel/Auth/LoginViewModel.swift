// LoginViewModel.swift

import Foundation
import Combine
import SwiftUI
import GoogleSignIn

class LoginViewModel: ObservableObject {
    static let shared = LoginViewModel()
    @Published var user: User? = nil
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var toast: Toast?
    @AppStorage("isLogged") var isLogged: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(handle401), name: .didReceive401, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleErrorNotification(_:)), name: .didReceiveError, object: nil)
    }
    
   deinit {
       NotificationCenter.default.removeObserver(self, name: .didReceive401, object: nil)
       NotificationCenter.default.removeObserver(self)
   }
    
    @objc private func handleErrorNotification(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? String {
            DispatchQueue.main.async {
                self.toast = Toast(
                    style: .error,
                    message: message,
                    duration: 3.0,
                    width: .infinity
                )
            }
        }
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
        
        isLoading = true
        
        FetchService().executeRequest(url: "/auth/login",
                                      method: "POST",
                                      data: ["username": username, "password": password]
        ) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
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
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to save user to keychain."
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid username or password."
                    }
                }
            }
        }
    }
    
    // MARK: - Google Sign-In
    func signInWithGoogle() {
        guard let presentingViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            self.errorMessage = "No root view controller found"
            return
        }

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
                }
                return
            }

            guard let result = result,
                  let idToken = result.user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to get Google ID token"
                }
                return
            }

            // Send Google ID token to your backend
            self?.authenticateWithBackend(idToken: idToken, provider: .google)
        }
    }
    
    // MARK: - APPLE Sign-in
    func signInWithApple(idToken: String) {
        self.authenticateWithBackend(idToken: idToken, provider: .apple)
    }
    
    private func authenticateWithBackend(idToken: String, provider: AuthProvider) {
        FetchService().executeRequest(
            url: provider == .apple ? "/auth/apple" : "/auth/google",
            method: "POST",
            data: ["idToken": idToken, "clientType": "ios"]
        ) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Authentication failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received from server"
                }
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                // Save the user to the keychain
                do {
                    try KeychainService.instance.secureStore(user, forKey: "SESSION")
                    DispatchQueue.main.async {
                        self?.user = user
                        self?.isLogged = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to save user to keychain."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to decode user data from server."
                }
            }
        }
    }
    
    func signOut() {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        
        // Clear local session
        KeychainService.instance.clear(forKey: "SESSION")
        
        DispatchQueue.main.async {
            self.user = nil
            self.isLogged = false
            self.username = ""
            self.password = ""
            self.errorMessage = nil
        }
    }
        
    func checkToken(){
        let stringSession = KeychainService.instance.secureGet(forKey: "SESSION")
        if let session = stringSession {
            let user = try? JSONDecoder().decode(User.self, from: session.data(using: .utf8)!)
            if let tokenExpiresAt = user?.refresh_expires_at {
                DispatchQueue.main.async {
                    if Date.isTokenValid(expiresAt: tokenExpiresAt) {
                        self.isLogged = true
                    } else {
                        self.isLogged = false
                    }
                }
            }
        } else {
            self.isLogged = false
        }
    }
}
