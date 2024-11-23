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
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            } else {
                VStack(alignment: .leading){
                    Text(message.content)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
    }
}
