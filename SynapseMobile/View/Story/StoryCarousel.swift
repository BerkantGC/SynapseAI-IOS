import Foundation
import SwiftUI

struct StoryCarousel: View {
    @ObservedObject var viewModel: StoryViewModel = StoryViewModel()
    let username: String
    @State private var currentIndex = 0
    @State private var progress: CGFloat = 0.0 // Progress bar value for the active story
    @State private var timerActive = true // Timer control flag
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // Increment progress every 0.1 seconds
    var animationNamespace: Namespace.ID
    
    private let pageWidth: CGFloat = UIScreen.main.bounds.width
    private let pageHeight: CGFloat = UIScreen.main.bounds.height / 1.2
    private let storyDuration: CGFloat = 6.0 // Story duration in seconds
    
    var body: some View {
        ZStack {
            // Story Images
            TabView(selection: $currentIndex) {
                ForEach(0..<viewModel.stories.count, id: \.self) { index in
                    let imageURL = viewModel.stories[index].image
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .matchedGeometryEffect(id: "story\(viewModel.stories[index].id)", in: animationNamespace)
                            .frame(width: pageWidth, height: pageHeight)
                            .clipped()
                            .tag(index)
                            .onTapGesture { location in
                                handleTapGesture(location: location, totalPages: viewModel.stories.count)
                            }
                    } placeholder: {
                        ProgressView()
                            .frame(width: pageWidth, height: pageHeight)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Disable default dots
            .onChange(of: currentIndex) { _ in
                resetTimer()
            }
            
            // Pagination Dots and Progress
            VStack {
                // Progress Bars
                HStack(spacing: 5) {
                    ForEach(0..<viewModel.stories.count, id: \.self) { index in
                        ProgressBar(
                            progress: index < currentIndex ? 1.0 : (index == currentIndex ? progress : 0.0)
                        )
                        .frame(height: 4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.getUserStories(username: username)
        }
        .onReceive(timer) { _ in
            if timerActive {
                updateProgress(totalPages: viewModel.stories.count)
            }
        }
    }
    
    // Handle tap gesture to navigate stories
    private func handleTapGesture(location: CGPoint, totalPages: Int) {
        timerActive = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.5)) {
            if location.x > pageWidth / 2 {
                goToNextStory(totalPages: totalPages)
            } else {
                goToPreviousStory(totalPages: totalPages)
            }
        }
        timerActive = true
    }
    
    // Navigate to the next story
    private func goToNextStory(totalPages: Int) {
        currentIndex = (currentIndex + 1) % totalPages
    }
    
    // Navigate to the previous story
    private func goToPreviousStory(totalPages: Int) {
        currentIndex = (currentIndex - 1 + totalPages) % totalPages
    }
    
    // Update the progress for the active story
    private func updateProgress(totalPages: Int) {
        withAnimation(.smooth){
            if progress < 1.0 {
                progress += 0.1 / storyDuration
            } else {
                progress = 0.0
                goToNextStory(totalPages: totalPages)
            }
        }
    }
    
    // Reset the timer when navigating manually
    private func resetTimer() {
        progress = 0.0
    }
}

// Custom Progress Bar View
struct ProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                Capsule()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 4)
        .animation(.snappy, value: progress)
    }
}
