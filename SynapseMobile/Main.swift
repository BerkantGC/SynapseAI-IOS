//
//  Main.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import SwiftUI

struct Main: View {
    @StateObject private var authViewModel = LoginViewModel.shared
   
    var body: some View{
        ZStack{
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
