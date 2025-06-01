//
//  UserChatCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 21.11.2024.
//

import Foundation
import SwiftUI

struct UserChatCard: View {
    var chat: SessionModel;
    
    var body: some View {
        HStack{
            ProfileImageView(imageData: nil, imageUrl: chat.image, size: 40)
        
            VStack(alignment: .leading){
                Text(chat.user)
                    .font(.headline)
                
                Text(chat.last_message)
                    .font(.subheadline)
            }
            
            Spacer()
            
            if let last_message_date = Date().convertDateToString(date: chat.last_message_date){
                Text(last_message_date)
                   .font(.subheadline)
            }

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        Divider()
        
    }
}
