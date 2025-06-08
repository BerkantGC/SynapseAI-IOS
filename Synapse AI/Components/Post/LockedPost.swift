//
//  LockedPost.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 7.06.2025.
//

import SwiftUI

struct LockedPost: View {
    let onUnlockTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)

            Text("This post is too positive.")
                .font(.headline)

            Button(action: onUnlockTap) {
                Text("😊 Smile to unlock")
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(width: .infinity, height: UIScreen.main.bounds.height/2)
    }
}
