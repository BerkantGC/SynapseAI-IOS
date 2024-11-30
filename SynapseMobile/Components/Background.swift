//
//  Background.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import SwiftUI

struct Background: View {
    var body: some View {
        LinearGradient(colors: [
            Color.black,
            Color("LoginBG").opacity(1),
        ], startPoint: .top, endPoint: .bottom).frame(width: .infinity, height: .infinity)
            .ignoresSafeArea(.all)
    }
}
