//
//  CameraView.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 7.06.2025.
//

import SwiftUI
import AVFoundation
import MediaPipeTasksVision

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text(cameraManager.smileDetected ? "😊 Gülümsüyorsun!" : "😐 Henüz gülümseme yok")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}
