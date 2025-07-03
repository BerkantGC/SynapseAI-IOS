//
//  EnhanceButton.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 21.06.2025.
//

import SwiftUI

struct EnhanceButton: View {
    @Binding var showEnhanceModal: Bool;
    
    var body: some View {
        Button {
            showEnhanceModal = true
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text("Enhance")
            }
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.yellow, .red, .bgGradientStart]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
