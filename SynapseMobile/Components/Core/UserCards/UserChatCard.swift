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
            AsyncImage(url: URL(string: chat.image ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
                
        
            VStack(alignment: .leading){
                Text(chat.user)
                    .font(.headline)
                
                Text(chat.last_message ?? "")
                    .font(.subheadline)
            }
            
            Spacer()
            
            if chat.last_message_date != nil{
                if let last_message_date = Date().convertDateToString(date: chat.last_message_date!){
                    Text(last_message_date)
                       .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
        Divider()
        
    }
}
