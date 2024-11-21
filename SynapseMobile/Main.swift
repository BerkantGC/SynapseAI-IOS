//
//  Main.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import SwiftUI

struct Main: View {
    @ObservedObject private var authViewModel = LoginViewModel()
    
     
    var body: some View{
        VStack {
            if authViewModel.isLogged {
                TabsView()
                    .environmentObject(authViewModel)
                    .navigationTitle("Synapse")
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            } 
        }.onAppear {
            authViewModel.checkToken()
        }
    }
}

#Preview {
    Main()
}
