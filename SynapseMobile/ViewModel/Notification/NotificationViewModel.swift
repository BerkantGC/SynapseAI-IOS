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
}
