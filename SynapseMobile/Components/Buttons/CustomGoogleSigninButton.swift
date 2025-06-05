//
//  CustomGoogleSigninButton.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 5.06.2025.
//

import SwiftUI
import GoogleSignIn

struct CustomGoogleSigninButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(.googleIcon)
                    .resizable()
                    .frame(width: 15, height: 15)
                
                Text("Sign in with Google")
                    .foregroundColor(.black)
                    .font(.subheadline)
            }
            .padding(5)
            .frame(height: 40)
            .cornerRadius(8)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .padding(.horizontal, 5)
    }
}
