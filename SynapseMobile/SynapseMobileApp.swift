//
//  SynapseMobileApp.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import SwiftUI
import GoogleSignIn

@main
struct SynapseMobileApp: App {
    init(){
        @EnvironmentKey("GOOGLE_CLIENT_ID")
        var clientId: String
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
    
    var body: some Scene {
        WindowGroup {
            Main()
        }
    }
}
