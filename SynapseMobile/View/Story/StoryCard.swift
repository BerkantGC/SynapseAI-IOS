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
            VStack(spacing: 8) {
                ZStack {
                    // Gradient border
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 76, height: 76)
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    ProfileImageView(imageData: nil, imageUrl: story.profile_picture, size: 70)
                    .matchedGeometryEffect(id: "story\(story.id)", in: animationNamespace)
                }
                
                Text(story.user)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(width: 80)
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
