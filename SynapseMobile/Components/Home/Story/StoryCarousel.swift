//
//  StoryCarousel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 16.11.2024.
//

import Foundation
import SwiftUI

struct StoryCarousel: View {
    @ObservedObject var viewModel: StoryViewModel = StoryViewModel()
    let username: String
    @State private var position: Int?
    @State private var currentIndex = 0
    var animationNamespace: Namespace.ID
    
    private let pageWidth: CGFloat = UIScreen.main.bounds.width
    private let pageHeight: CGFloat = UIScreen.main.bounds.height/1.2
    private let animationDuration: CGFloat = 0.3
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollViewReader { proxy in
            let totalPages = viewModel.stories.count
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        let imageURL = "http://localhost:8080/image/\(viewModel.stories[index].image).png"
                        AsyncImage(url: URL(string: imageURL)!) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .matchedGeometryEffect(id: viewModel.stories[index].id, in: animationNamespace)
                                .frame(width: pageWidth, height: pageHeight)
                                .tag(index)
                                .onTapGesture { location in
                                    withAnimation {
                                        if location.x >= pageWidth/2 {
                                            currentIndex = (currentIndex + 1) % totalPages
                                            proxy.scrollTo(currentIndex)
                                        } else {
                                            currentIndex = (currentIndex - 1) % totalPages
                                            proxy.scrollTo(currentIndex)
                                        }
                                    }
                                }
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }.onReceive(timer){_ in
                    currentIndex = (currentIndex + 1) % totalPages
                    proxy.scrollTo(currentIndex)
                }
                .scrollTargetLayout()
            }
            
            GeometryReader{ geometry in
                // Pagination Dots
                HStack(spacing: 5) {
                    Spacer().frame(width: 10)
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .frame(
                                width: geometry.size.width / CGFloat(totalPages*2),
                                height: 10
                            )
                            .foregroundStyle(
                                index == currentIndex ? .text : Color.gray
                            )
                            .onTapGesture {
                                withAnimation() {
                                    currentIndex = index
                                    proxy.scrollTo(index, anchor: .center)
                                }
                            }
                    }
                    Spacer().frame(width: 10)
                }.frame(maxWidth: .infinity, alignment: .center) // Center horizontally
                .padding(.top)
            }
        }.scrollPosition(id: $position)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .onAppear(){
            viewModel.getUserStories(username: username)
        }
    }
}


#Preview {
    Main()
}
