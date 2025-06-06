//
//  VideoView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 5.06.2025.
//

import SwiftUI
import AVKit
import AVFoundation

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    var player: AVPlayer? {
        get { (layer as? AVPlayerLayer)?.player }
        set { (layer as? AVPlayerLayer)?.player = newValue }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        (layer as? AVPlayerLayer)?.videoGravity = .resizeAspectFill
    }
}

struct CustomVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.player = player
    }
}

struct HLSPlayerView: View {
    let url: String
    @StateObject private var playerManager: PlayerManager
    @State private var showControls = true
    @State private var tapCount = 0
    @State private var lastTapTime = Date()
    @State private var controlsTimer: Timer?
    @State private var progressTimer: Timer?
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State var onLike: (() -> Void)?
    @State var post: Post?
    var isDetail: Bool
    
    init(url: String, onLike: (()->Void)? = nil, post: Post? = nil, isDetail: Bool = false, isFilePath: Bool? = false) {
        self.url = url
        self.onLike = onLike
        self.post = post
        self.isDetail = isDetail
        self._playerManager = StateObject(wrappedValue: PlayerManager(url: url, isFilePath: isFilePath!))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                backgroundGradient
                
                // Video player
                videoPlayerView
                    .clipShape(RoundedRectangle(cornerRadius: 0))
                    .scaleEffect(isDragging ? 0.95 : 1.0)
                    .offset(dragOffset)
                    .gesture(combinedGestures)
                    .onAppear {
                        setupPlayer()
                    }
                    .onDisappear {
                        cleanup()
                    }

                // Controls overlay
                if showControls {
                    controlsOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Like hearts animation
                likeHeartsOverlay
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                playerManager.pause()
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showControls)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    colors: [.purple.opacity(0.8), .pink.opacity(0.8), .orange.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var videoPlayerView: some View {
        CustomVideoPlayer(player: playerManager.player)
    }
    
    private var controlsOverlay: some View {
        VStack {
            // Top controls (if needed)
            Spacer()
            
            // Bottom controls
            HStack {
                Spacer()
                
                // Control buttons
                VStack(spacing: 16) {
                    playPauseButton
                    muteButton
                    if !isDetail && post != nil {
                        navigateButton
                    }
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 20)
            
            // Time labels
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatTime(playerManager.currentTime))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Text(formatTime(playerManager.duration))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            
            // Progress bar
            VideoProgressView(
                currentTime: playerManager.currentTime,
                duration: playerManager.duration,
                onSeek: { time in
                    playerManager.seek(to: time)
                }
            )
            .padding(.horizontal, 20)
        }
    }
    
    private var likeHeartsOverlay: some View {
        ForEach(0..<tapCount, id: \.self) { index in
            LikeHeartView()
                .offset(
                    x: CGFloat.random(in: -60...60),
                    y: CGFloat.random(in: -120...120)
                )
        }
    }
    
    // MARK: - Control Buttons
    
    private var playPauseButton: some View {
        Button {
            playerManager.togglePlayPause()
            provideFeedback(.medium)
            resetControlsTimer()
        } label: {
            Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(controlButtonBackground([.pink, .purple, .orange]))
        }
    }

    private var muteButton: some View {
        Button {
            playerManager.toggleMute()
            provideFeedback(.light)
            resetControlsTimer()
        } label: {
            Image(systemName: playerManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(controlButtonBackground([.cyan, .blue, .indigo]))
        }
    }

    private var navigateButton: some View {
        NavigationLink(destination: PostDetailCard(viewModel: PostViewModel(post: post!), animationNamespace: Namespace().wrappedValue)) {
            VStack(spacing: 4) {
                Image(systemName: "arkit")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(width: 50, height: 50)
            .background(controlButtonBackground([.green, .mint, .teal]))
        }
    }
    
    private func controlButtonBackground(_ colors: [Color]) -> some View {
        Circle()
            .fill(.ultraThinMaterial)
            .overlay(
                Circle().stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            )
    }
    
    // MARK: - Gestures
    
    private var combinedGestures: some Gesture {
        tapGesture
    }
    
    private var tapGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                handleSingleTap()
            }
            .simultaneously(with:
                TapGesture(count: 2)
                    .onEnded {
                        handleDoubleTap()
                    }
            )
    }
    
    // MARK: - Gesture Handlers
    
    private func handleSingleTap() {
        showControls.toggle()
        lastTapTime = Date()
        if showControls {
            resetControlsTimer()
        }
    }
    
    private func handleDoubleTap() {
        tapCount += 1
        lastTapTime = Date()
        
        if let handleLike = onLike {
            handleLike()
        }
        
        // Reset tap count after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if Date().timeIntervalSince(lastTapTime) >= 1.4 {
                tapCount = 0
            }
        }
        
        provideFeedback(.light)
    }
    
    private func handleSwipeDown() {
        // Could be used to dismiss the player or minimize
        playerManager.pause()
    }
    
    private func handleSwipeUp() {
        // Could be used for fullscreen or other actions
    }
    
    // MARK: - Setup and Cleanup
    
    private func setupPlayer() {
        playerManager.setup()
        startProgressTimer()
        resetControlsTimer()
    }
    
    private func cleanup() {
        playerManager.cleanup()
        stopTimers()
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            playerManager.updateProgress()
        }
    }
    
    private func stopTimers() {
        controlsTimer?.invalidate()
        progressTimer?.invalidate()
        controlsTimer = nil
        progressTimer = nil
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            withAnimation {
                showControls = false
            }
        }
    }
    
    // MARK: - Utility Functions
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func provideFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Player Manager

@MainActor
class PlayerManager: ObservableObject {
    let player: AVPlayer
    private let url: String
    
    @Published var isPlaying = false
    @Published var isMuted = true
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isBuffering = false
    
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var itemObserver: NSKeyValueObservation?
    
    init(url: String, isFilePath: Bool) {
        @EnvironmentKey("BASE_URL")
        var baseURL: String;
        
        if isFilePath, FileManager.default.fileExists(atPath: url) {
            self.url = url
            self.player = AVPlayer(url: URL(fileURLWithPath: url))
        } else {
            let fullUrl = URL(string: url.contains(baseURL) ? url : "\(baseURL)\(url)")!
            self.url = url
            self.player = AVPlayer(url: fullUrl)
        }
    }
    
    func setup() {
        player.isMuted = isMuted
        
        // Add time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        // Observe player item duration
        itemObserver = player.observe(\.currentItem?.duration) { [weak self] player, _ in
            if let duration = player.currentItem?.duration.seconds, !duration.isNaN {
                self?.duration = duration
            }
        }
        
        // Observe player status
        statusObserver = player.observe(\.timeControlStatus) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.isPlaying = player.timeControlStatus == .playing
                self?.isBuffering = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
            }
        }
        
        // Add notification for end of playback
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
        
        player.play()
    }
    
    func cleanup() {
        player.pause()
        
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        
        statusObserver?.invalidate()
        itemObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    func toggleMute() {
        isMuted.toggle()
        player.isMuted = isMuted
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func seek(by seconds: Double) {
        let newTime = currentTime + seconds
        let clampedTime = max(0, min(newTime, duration))
        seek(to: clampedTime)
    }
    
    func updateProgress() {
        // This is called by the timer to update UI
        // The actual time update is handled by the time observer
    }
}

// MARK: - Supporting Views

struct LikeHeartView: View {
    @State private var animate = false
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 35))
            .foregroundStyle(
                LinearGradient(
                    colors: [.pink, .red, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(animate ? 1.8 : 0.5)
            .opacity(animate ? 0 : 1)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    animate = true
                    yOffset = -150
                }
            }
    }
}

struct VideoProgressView: View {
    let currentTime: Double
    let duration: Double
    let onSeek: (Double) -> Void
    
    @State private var isSeeking = false
    @State private var seekValue: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            Slider(
                value: Binding(
                    get: { isSeeking ? seekValue : (currentTime / max(duration, 1)) },
                    set: { newValue in
                        seekValue = newValue
                        if !isSeeking {
                            isSeeking = true
                        }
                    }
                ),
                onEditingChanged: { editing in
                    if !editing && isSeeking {
                        onSeek(seekValue * duration)
                        isSeeking = false
                    }
                }
            )
            .accentColor(.white)
            .frame(height: 20)
        }
    }
}

// MARK: - Preview

#Preview {
    HLSPlayerView(url: "http://localhost:8080/videos/hls/c880b0aa-92b2-410b-9905-4c07e76eff81/c880b0aa-92b2-410b-9905-4c07e76eff81.m3u8")
        .frame(height: 600)
        .padding()
}
