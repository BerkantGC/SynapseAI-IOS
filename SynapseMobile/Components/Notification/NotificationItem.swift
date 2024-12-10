//
//  NotificationItem.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/11/24.
//

import SwiftUI

struct NotificationItem : View {
    
    var notification: NotificationModel
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                if let profileImage = notification.from.profile_picture {
                    AsyncImage(url: URL(string: profileImage)){ image in
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .padding(.trailing, 10)
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .padding(.trailing, 10)
                        
                    }
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.trailing, 10)
                }
                
                VStack(alignment: .leading){
                    Text(notification.title)
                        .font(.headline)
                    Text(notification.description ?? "")
                        .font(.subheadline)
                        .lineLimit(2)
                }
            }
            Divider()
        }
    }
}
