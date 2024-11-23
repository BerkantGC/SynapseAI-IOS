//
//  MessageView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 20.11.2024.
//

import Foundation
import SwiftUI

struct MessageView: View {
    @StateObject private var socketManager = SocketManagerService.shared
    @State private var isShowing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                ScrollView {
                    VStack {
                        // Display chat sessions
                        ForEach(socketManager.sessions) { session in
                            UserChatCard(chat: session)
                                .onTapGesture {
                                    socketManager.selectedSession = session
                                    isShowing.toggle()
                                }
                                // Navigate to ChatView when isShowing is true
                                .navigationDestination(isPresented: $isShowing) {
                                    ChatView()
                                }
                        }
                    }
                    .onAppear {
                        socketManager.connect()
                    }
                }
            }
            .navigationTitle("Mesajlarım")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

 
#Preview{
    Main()
}
