//
//  NotificationItem.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/11/24.
//

import SwiftUI

struct NotificationItem: View {
    var notification: NotificationModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                ProfileImageView(
                    imageData: nil,
                    imageUrl: notification.from.profile_picture,
                    size: 50
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)

                    if let description = notification.description {
                        Text(description)
                            .font(.subheadline)
                            .lineLimit(2)
                            .foregroundColor(.gray)
                    }

                    if notification.kind == "FOLLOW_REQUEST" {
                        HStack(spacing: 8) {
                            Button(action: {
                                notificationViewModel.handleFollowReq(
                                    notification_id: notification.id,
                                    status: .ACCEPTED
                                )
                            }) {
                                Text("Accept")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green)
                                    .cornerRadius(5)
                            }

                            Button(action: {
                                notificationViewModel.handleFollowReq(
                                    notification_id: notification.id,
                                    status: .REJECTED
                                )
                            }) {
                                Text("Reject")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()
        }
    }
}
