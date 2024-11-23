//
//  ChatView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation
import SwiftUI

struct ChatView : View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var socketManager = SocketManagerService.shared
    
    var body: some View {
        ZStack{
            Background()
            ScrollView{
                VStack {
                    ForEach(socketManager.messages){ message in
                        MessageCard(message: message)
                    }
                }.frame(width: .infinity)
                .onAppear {
                    socketManager.getMessages()
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear(){
            UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "arrow.left")
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.left")
            UINavigationBar.appearance().isTranslucent = true
            UINavigationController().interactivePopGestureRecognizer?.isEnabled = true
            
        }
    }
}
