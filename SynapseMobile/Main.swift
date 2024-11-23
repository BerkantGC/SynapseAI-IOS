//
//  Main.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import SwiftUI

struct Main: View {
    @ObservedObject private var authViewModel = LoginViewModel()
    
    init() {
        authViewModel.checkToken()
        SocketManagerService.shared.connect()
    }
   
    var body: some View{
        if authViewModel.isLogged {
            TabsView()
                .environmentObject(authViewModel)
                .navigationTitle("Synapse")
        } else {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
} 

#Preview {
    Main()
}
