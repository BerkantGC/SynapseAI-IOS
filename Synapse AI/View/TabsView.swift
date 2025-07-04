//
//  Home.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 10.11.2024.
//

import Foundation
import SwiftUI

enum Tab: Int {
    case home = 0
    case explore = 1
    case upload = 2
    case messages = 3
    case profile = 4
}

struct TabsView: View {
    @State var selectedTab: Tab = .home
    @State var notifications: [NotificationModel]?
    @State var socketInitialized = false
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .systemGray
        UITabBar.appearance().backgroundColor = .bgGradientStart
        sendAPNTokenToBackend()
    }
    
    func sendAPNTokenToBackend () {
        if let apns_token = UserDefaults.standard.string(forKey: "apns_token") {
            FetchService().executeRequest(url: "/device", method: "POST", data: ["token": apns_token]) { data, response, error in
                
                if let httpResponse = response as! HTTPURLResponse? {
                    print("device token sent status: \(httpResponse.statusCode)")
                }
                
            }
        }
    }
    
    var body: some View {
        TabView {
            HomeView()
                .onAppear() {
                    self.selectedTab = .home
                }
                .tabItem {
                    Image(systemName: "house")
                }
            ExploreView()
                .onAppear() {
                    self.selectedTab = .explore
                }
                .tabItem {
                    Image(systemName: "globe.europe.africa")
                }
            UploadView()
                .onAppear() {
                    self.selectedTab = .upload
                }
                .tabItem {
                    Image(systemName: "plus.viewfinder")
                }
            ChatListView()
                .onAppear() {
                    self.selectedTab = .messages
                }
                .tabItem {
                    Image(systemName: "message")
                }
            MyProfileView()
                .onAppear() {
                    self.selectedTab = .profile
                }
                .tabItem {
                    Image(systemName: "person")
                }
        }.accentColor(.text)
        .onAppear {
            if !socketInitialized {
                SocketManagerService.shared.resetAndReconnect()
                socketInitialized = true
            }
        }

    }
}

#Preview {
    Main()
}
