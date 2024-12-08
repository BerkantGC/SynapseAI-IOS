//
//  Background.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import SwiftUI

struct Background: View {
    // Access the current color scheme environment value
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LinearGradient(colors: [
            colorScheme == .dark
            ? Color.black
            : Color.white,
            Color("LoginBG")
        ], startPoint: .top, endPoint: .bottom)
        .frame(width: .infinity, height: .infinity)
        .ignoresSafeArea(.all)
    }
}
