import SwiftUI
import Kingfisher

// MARK: - Enhanced Story Card
struct StoryCard: View {
    var story: StoryModel
    let animationNamespace: Namespace.ID
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background story image with black filter
                    KFImage(URL(string: story.image))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 240, height: 160)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            // Black filter overlay
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.4))
                        )
                        .matchedGeometryEffect(id: "story\(story.id)", in: animationNamespace)
                
                VStack {
                    HStack {
                        // Profile picture in top-left corner
                        ProfileImageView(
                            imageData: nil,
                            imageUrl: story.profile_picture,
                            size: 32
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 12)
                    
                    Spacer()
                    
                    // Username at bottom
                    HStack {
                        Text(story.user)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                    }
                    .padding(.bottom, 12)
                    .padding(.horizontal, 12)
                }
            }
            .frame(width: 240, height: 160)
        }
        .buttonStyle(StoryCardButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// Custom button style for story cards
struct StoryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
