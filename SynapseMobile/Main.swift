//
//  Main.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import SwiftUI

struct Main: View {
    @State var isLogged = false
    
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
    
    init() {
        // Custom initialization logic if needed
    }
    
    var body: some View{
        VStack {
            if isLogged {
                TabsView()
            } else {
                LoginView()
            }
        }.onAppear {
            checkToken()
        }
    }
}
