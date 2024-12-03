//
//  MessageView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 20.11.2024.
//

import Foundation
import SwiftUI

struct ChatListView: View {
    @StateObject private var socketManager = SocketManagerService.shared
    @State var isShowing = false
    @State var selectedUser: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                ScrollView {
                    VStack {
                        ChatsHeader(isNavigating: $isShowing, selectedUser: $selectedUser)
                        
                        // Display chat sessions
                        if let sessions = socketManager.sessions?.sessions{
                            ForEach(sessions) { session in
                                UserChatCard(chat: session)
                                    .onTapGesture {
                                        socketManager.selectedSession = session
                                        isShowing.toggle()
                                    }
                            }
                        }
                    }
                    // Navigate to ChatView when isShowing is true
                    .navigationDestination(isPresented: $isShowing) {
                        ChatView(selectedUserId: $selectedUser)
                    }
                    .onAppear {
                        socketManager.send(to: "/app/get-sessions")
                    }
                }
            }
            .navigationTitle("Mesajlarım")
        }
    }
}

 
#Preview{
    Main()
}
