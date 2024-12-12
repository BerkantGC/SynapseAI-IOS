//
//  NotificationViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/11/24.
//

import SwiftUI

final class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    @Published var total_count: Int = 0
    @Published var isLoading: Bool = true
    @Published var error: String = ""
    
    init(){
        let socketManager = SocketManagerService.shared
        socketManager.connect()
        notifications = socketManager.notifications
        total_count = socketManager.notifications.count
        isLoading = false
    }
    
    func handleFollowReq (notification_id: Int,status: FollowStatus) {
        let index = notifications.firstIndex(where: { $0.id == notification_id })!
        
        FetchService().executeRequest(url: "/profile/\(notifications[index].from.user_id)/follow-request", method: "PUT", data: ["status": status.rawValue]){
            data, response, error in
            
            if let error = error {
                self.error = error.localizedDescription
            }
            
            if data != nil {
                self.notifications.remove(at: index)
            }
        }
    }
}
