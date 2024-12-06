//
//  ChatView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation
import SwiftUI

struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var socketManager = SocketManagerService.shared
    @Binding var selectedUserId: Int?
    
    var body: some View {
        ZStack {
            Background()
            
            VStack{
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(socketManager.messages) { message in
                                MessageCard(message: message)
                                    .id(message.id)
                            }
                        }.padding(.horizontal, 5)
                    }
                    .onAppear {
                        configureNavigationAppearance()
                        socketManager.proxy = proxy
                        DispatchQueue.main.async {
                            if let session_id = socketManager.selectedSession?.session_id{
                                socketManager.subscribe(to: "/user/topic/private/\(session_id)")
                                socketManager.send(body: "\(session_id)",to: "/app/chat/get-private-messages")
                            }
                        }
                    }
                    .onDisappear(){
                        socketManager.unsubscribe()
                    }
                }
                
                MessageInput(selectedUserId: $selectedUserId)
                    .padding()
            }.toolbar(.hidden, for: .tabBar)
            .navigationTitle(socketManager.selectedSession?.user ?? "")
        }
    }

    private func configureNavigationAppearance() {
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "arrow.left")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.left")
        UINavigationController().interactivePopGestureRecognizer?.isEnabled = true
    }
}

#Preview {
    Main()
}
