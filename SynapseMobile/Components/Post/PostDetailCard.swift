import Foundation
import SwiftUI

struct PostDetailCard: View {
    var post: Post
    var animationNamespace: Namespace.ID
    @State private var descriptionOffset: CGFloat = UIScreen.main.bounds.height
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Dynamic Background
            Background()
                .ignoresSafeArea()
                .animation(.easeInOut, value: descriptionOffset)
           
            // Main Post Image
            AsyncImage(url: URL(string: post.image ?? "")) { image in
                image
                    .resizable()
                    .matchedGeometryEffect(id: post.id,
                                           in: animationNamespace)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(descriptionOffset == 0 ? 1 : 1.05)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: descriptionOffset)
            } placeholder: {
                ProgressView()
            }
            .zIndex(1)
            
            // Description Container
            VStack(spacing: 10) {
                Spacer()
                
                HStack {
                    Text(post.title ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(post.full_name ?? "")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("@\(post.username ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                
                if let description = post.content {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .padding()
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.bottom)
            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                                       startPoint: .bottom, endPoint: .top))
            .cornerRadius(30)
            .offset(y: descriptionOffset + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation.height > 0 ? gesture.translation.height : 0
                    }
                    .onEnded { gesture in
                        if dragOffset > 200 {
                            withAnimation(.easeInOut) {
                                descriptionOffset = UIScreen.main.bounds.height
                            }
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .onAppear {
                withAnimation(.smooth) {
                    descriptionOffset = 0
                }
            }
            .zIndex(2)
        }
        .frame(alignment: .center)
        .ignoresSafeArea()
    }
}
