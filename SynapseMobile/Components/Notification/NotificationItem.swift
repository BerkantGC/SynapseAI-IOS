//
//  NotificationItem.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/11/24.
//

import SwiftUI

struct NotificationItem : View {
    var notification: NotificationModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 10){
                ProfileImageView(imageData: nil, imageUrl: notification.from.profile_picture, size: 50)
                
                VStack(alignment: .leading){
                    Text(notification.title)
                        .font(.headline)
                    if let description = notification.description{
                        Text(description)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                }
                
                
                HStack(spacing: 5){
                    Button(action: {
                        notificationViewModel.handleFollowReq(notification_id: notification.id, status: .ACCEPTED)
                    }){
                        Text("Onayla")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.green)
                            .cornerRadius(5)
                    }
                    Button(action: {
                        print("Tapped")
                    }){
                        Text("Reddet")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .cornerRadius(5)
                    }
                        
                }
                
                
            }.padding(10)
            Divider()
        }
    }
}
