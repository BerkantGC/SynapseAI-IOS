//
//  MessageView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 20.11.2024.
//

import Foundation
import SwiftUI

struct MessageView : View {
    @StateObject private var socketManager = SocketManagerService.shared
    
    var body: some View {
        VStack {
            Text("Mesajlarım")
                .font(.title)
                .padding()
            List(socketManager.sessions) { session in
                VStack(alignment: .leading) {
                    UserChatCard(chat: session)
                }
            }
        }.onAppear {
            socketManager.connect()
            
        }
        
    }
}
 
#Preview{
    Main()
}
