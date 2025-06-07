//
//  AuthBackground.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import SwiftUI

struct AuthBackground: View {
    var body: some View {
        Image("LoginBG")
            .resizable()
            .shadow(radius: 5)
            .aspectRatio(contentMode: .fit)
            .frame(width: .infinity, height: UIScreen.main.bounds.height,
                   alignment: .top)
            .edgesIgnoringSafeArea(.all)
        
        // Gradient overlay to create a smooth transition
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                Color("LoginBG").opacity(1) // End with solid background color
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: .infinity, height: UIScreen.main.bounds.height,
               alignment: .top)
        .edgesIgnoringSafeArea(.all)
    }
}
