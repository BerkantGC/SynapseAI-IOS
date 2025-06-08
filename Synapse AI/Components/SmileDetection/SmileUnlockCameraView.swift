//
//  SmileUnlockCameraView.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 7.06.2025.
//
import SwiftUI

struct SmileUnlockCameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var cameraManager = CameraManager()
    @State private var showUnlockAnim = false
    @State private var showUnlockedText = false
    
    let onSmileDetected: () -> Void

    var body: some View {
        ZStack {
            // Kamera arka plan
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
                .blur(radius: showUnlockAnim ? 6 : 0)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )

            // Gülümseme mesajı
            if !showUnlockAnim {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: cameraManager.smileDetected ? "face.smiling.fill" : "face.dashed")
                        .font(.system(size: 60))
                        .foregroundColor(cameraManager.smileDetected ? .green : .white)
                        .scaleEffect(cameraManager.smileDetected ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: cameraManager.smileDetected)

                    Text(cameraManager.smileDetected ? "You smiled 🎉" : "Waiting for your smile...")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                    
                    Spacer().frame(height: 60)
                }
                .padding()
            }

            // Unlock animasyonu
            if showUnlockAnim {
                VStack {
                    LottieView(filename: "unlock_animation") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showUnlockedText = true
                        }

                        // 1 saniye sonra çık
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            dismiss()
                            onSmileDetected()
                        }
                    }
                    .frame(width: 150, height: 150)

                    if showUnlockedText {
                        Text("Unlocked. Keep smiling!")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.bottom, 80)
                .transition(.opacity)
            }
        }
        .onAppear {
            cameraManager.onSmileDetected = {
                if !showUnlockAnim {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    //SoundManager.shared.playSound(named: "unlock_sound")
                    withAnimation {
                        showUnlockAnim = true
                    }
                }
            }
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}
