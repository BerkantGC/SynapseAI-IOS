//
//  MessageCard.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation
import SwiftUI

struct MessageCard: View {
    var message: MessageModel
    
    var body: some View {
        HStack{
            if message.me {
                Spacer()
                VStack(alignment: .trailing){
                    Text(message.message)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    Image(systemName: message.seen_at != nil ? "checkmark.seal.fill" : "checkmark.seal")
                        .foregroundColor(.white)
                        .font(.callout)
                }
            } else {
                VStack(alignment: .leading){
                    Text(message.message)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }.padding(.vertical, 5)
    }
}
