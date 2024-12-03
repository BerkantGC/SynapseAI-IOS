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
            if let pp = chat.image{
                AsyncImage(url: URL(string: pp)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
            }else{
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
        
            VStack(alignment: .leading){
                Text(chat.user)
                    .font(.headline)
                
                Text(chat.last_message ?? "")
                    .font(.subheadline)
            }
            
            Spacer()
            
            if chat.last_message_date != nil{
                if let last_message_date = Date().convertDateToString(date: chat.last_message_date){
                    Text(last_message_date)
                       .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
        Divider()
        
    }
}
