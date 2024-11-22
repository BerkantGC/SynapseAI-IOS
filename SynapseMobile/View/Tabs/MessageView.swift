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
        ZStack{
            Background()
            ScrollView{
                VStack {
                    Text("Mesajlarım")
                        .font(.title)
                        .padding()
                    ForEach(socketManager.sessions) { session in
                        UserChatCard(chat: session)
                    }
                }
                .onAppear {
                    socketManager.connect()
                }
            }
        }
    }
}
 
#Preview{
    MessageView()
}
