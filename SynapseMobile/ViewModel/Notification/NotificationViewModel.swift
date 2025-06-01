//
//  NotificationViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/11/24.
//

import SwiftUI
import Combine

final class NotificationViewModel: ObservableObject {
    let socketManager = SocketManagerService.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var notifications: [NotificationModel] = []
    @Published var total_count: Int = 0
    @Published var isLoading: Bool = true
    @Published var error: String = ""

    init(){
        socketManager.connect()

        socketManager.$notifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in
                self?.notifications = updated
                self?.total_count = updated.count
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    func handleFollowReq (notification_id: Int,status: FollowStatus) {
        let index = notifications.firstIndex(where: { $0.id == notification_id })
        
        if let index = index {
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
}
