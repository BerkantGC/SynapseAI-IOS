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
                        socketManager.getMessages()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scrollToLatestMessage(using: proxy)
                        }
                    }
                } 
                
                MessageInput(selectedUserId: $selectedUserId)
                    .padding()
            }.toolbar(.hidden, for: .tabBar)
            .navigationTitle(socketManager.selectedSession?.user ?? "")
        }
    }

    private func scrollToLatestMessage(using proxy: ScrollViewProxy) {
        if let lastMessageID = socketManager.messages.last?.id {
            proxy.scrollTo(lastMessageID, anchor: .bottom)
        }
    }

    private func configureNavigationAppearance() {
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "arrow.left")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.left")
        UINavigationController().interactivePopGestureRecognizer?.isEnabled = true
    }
}
