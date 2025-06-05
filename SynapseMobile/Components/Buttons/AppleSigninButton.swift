//
//  AppleSigninButton.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 5.06.2025.
//

import AuthenticationServices
import SwiftUI

struct AppleSignInButton: View {
    var onCompletion: (String) -> Void

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                   let identityToken = appleIDCredential.identityToken,
                   let tokenString = String(data: identityToken, encoding: .utf8) {
                    onCompletion(tokenString)
                } else {
                    print("Apple Sign-In token parse error")
                }
            case .failure(let error):
                print("Authorization failed: \(error)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 45)
        .cornerRadius(8)
        .padding(.horizontal, 5)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}
