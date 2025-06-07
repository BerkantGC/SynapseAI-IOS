//
//  MessageInput.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation
import SwiftUI

struct MessageInput: View {
    @StateObject var socketManager = SocketManagerService.shared
    @Binding var selectedUser: String?
    
    var body: some View {
        ZStack{
            TextField("Message", text: $socketManager.newMessage)
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .foregroundColor(.text)
            Button(action: {
                if let session_id = socketManager.selectedSession?.session_id{
                    socketManager.send(body:
                                        ["message": socketManager.newMessage,
                                         "session_id": "\(session_id)",
                                        ],
                                       to: "/app/chat/private")
                }
                else {
                    if let selectedUser = selectedUser{
                        socketManager.send(body: ["message": socketManager.newMessage,
                                                  "newMessageTo": selectedUser], to: "/app/chat/private")
                    }
                }
                socketManager.newMessage = ""
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.text)
                    .rotationEffect(self.socketManager.newMessage.isEmpty ? .degrees(45) : .degrees(-45))
            }
            .offset(x: UIScreen.main.bounds.width / 2.5)
        }
    }
}
