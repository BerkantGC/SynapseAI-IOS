//
//  StoryCarouselItem.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 16.11.2024.
//

import SwiftUI

struct StoryCarouselItem : View{
    var image : String
    
    var body: some View {
        VStack{
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .padding(.horizontal, 10)
                .frame(width: .infinity, height: .infinity)
            
            Text("Berkant")
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}
