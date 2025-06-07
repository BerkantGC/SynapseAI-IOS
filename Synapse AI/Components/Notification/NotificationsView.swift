import Foundation
import SwiftUI

struct NotificationsView: View {
    @ObservedObject var notificationViewModel = NotificationViewModel()
    
    var body: some View {
        ZStack {
            Background()
            
            VStack {
                if notificationViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 20)
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(notificationViewModel.notifications) { notification in
                                NotificationItem(notification: notification)
                                    .environmentObject(notificationViewModel)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        notificationViewModel.resetNotifications()
                    }
                }
            }
        }
        .navigationTitle("Notifications")
    }
}
