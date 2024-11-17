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
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .systemGray
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
            Text("Mesajlarım")
                .onAppear() {
                    self.selectedTab = .messages
                }
                .tabItem {
                    Image(systemName: "message")
                }
            ProfileView()
                .onAppear() {
                    self.selectedTab = .profile
                }
                .tabItem {
                    Image(systemName: "person")
                }
        }
        .accentColor(.white)
    }
}

#Preview {
    Main()
}
