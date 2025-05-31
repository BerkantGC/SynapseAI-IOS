//
//  NotificationsView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/11/24.
//

import Foundation
import SwiftUI

struct NotificationsView: View {
    @ObservedObject var notificationViewModel = NotificationViewModel()
    
    var body: some View {
        ZStack {
            Background()
            
            VStack{
                if notificationViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 20)
                } else {
                    ScrollView {
                        ForEach(notificationViewModel.notifications) { notification in
                            NotificationItem(notification: notification)
                                .environmentObject(notificationViewModel)
                        }
                    }
                }
            }
        }
        .onAppear {
            //notificationViewModel.fetchNotifications()
        }.navigationTitle("Notifications")
    }
}

#Preview {
    Main()
}
