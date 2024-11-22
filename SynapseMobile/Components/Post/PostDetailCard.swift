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
            
            AsyncImage(url: URL(string: "http://localhost:8080/image/\(post.image ?? "").png")) { image in
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
                    VStack(alignment: .leading) {
                        Text(post.full_name!)
                            .font(.headline)
                        Text("@\(post.username!)")
                            .font(.subheadline)
                    }
                    Spacer()
                }.padding(.horizontal)
                
                Text(post.content!)
                    .font(.title2)
                    .padding()
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
            }.background(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.loginBG]), startPoint: .top, endPoint: .bottom))
                .offset(y: descriptionContainer)
        }
        .onAppear() {
            withAnimation(.smooth.delay(1)) {
                descriptionContainer = 0
            }
        }
        .frame(width: .infinity, height: .infinity)
        .toolbarVisibility(.hidden, for: .tabBar, .navigationBar)
        .zIndex(1)
        
    }
}
