//
//  PostDetailView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 22.11.2024.
//

import Foundation
import SwiftUI

struct PostDetailCard: View {
    var post: Post
    var animationNamespace: Namespace.ID
    @State var descriptionContainer: CGFloat = UIScreen.main.bounds.height
    
    
    var body: some View {
        ZStack {
            Background()
            
            AsyncImage(url: URL(string: post.image ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: post.id, in: animationNamespace)
            } placeholder: {
                ProgressView()
            }
            
            
           
                VStack{
                    Spacer()
                
                    
                    HStack {
                        Text(post.title!)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(post.full_name!)
                                .font(.headline)
                            Text("@\(post.username!)")
                                .font(.subheadline)
                        }
                    }.padding(.horizontal)
                    
                    
                    if let description = post.content {
                        Text(description)
                            .font(.title2)
                            .padding()
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    }
                }.background(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.loginBG]), startPoint: .top, endPoint: .bottom))
                    .offset(y: descriptionContainer)
                    .gesture(DragGesture().onChanged { value in
                        if value.translation.height > 0 {
                            descriptionContainer = value.translation.height
                        }
                    }.onEnded { value in
                        if value.translation.height > 200 {
                            descriptionContainer = 220
                        } else {
                            descriptionContainer = 0
                        }
                    })
            
        }
        .onAppear() {
            withAnimation(.smooth.delay(1)) {
                descriptionContainer = 0
            }
        }
        .frame(width: .infinity, height: .infinity)
        .zIndex(4)
        
    }
}
