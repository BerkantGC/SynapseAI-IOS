//
//  VideoGeneratorView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 6.06.2025.
//

import SwiftUI

struct VideoGeneratorView: View {
    @ObservedObject var viewModel = UploadViewModel.shared
    
    @State private var prompt = ""
    @State private var videoURL: String?
    @State private var isLoading = false
    @State private var showContinueButton = false
    
    var body: some View {
        ZStack {
            Background()

            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .aspectRatio(3/4, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Group {
                                if let video = videoURL {
                                    HLSPlayerView(url: video, isDetail: true, isFilePath: true)
                                        .cornerRadius(12)
                                } else {
                                    Text("Preview")
                                        .font(.title2.bold())
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                }.hideKeyboardOnTap()
                .padding(.horizontal)


                TextField("Enter prompt...", text: $prompt, axis: .vertical)
                    .lineLimit(3...6)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                Button(action: {
                    generateVideo()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        } else {
                            Image(systemName: "wand.and.stars")
                            Text("Generate")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary)
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                if showContinueButton && videoURL != nil {
                    HStack {
                        Spacer()
                    }
                }

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Generate")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {} label: { Color.clear }
            }
        }
    }

    private func generateVideo() {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        Task {
            let generated = await viewModel.generateVideo(prompt: prompt)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                videoURL = generated
                showContinueButton = true
            }
            isLoading = false
        }
    }
}

#Preview {
    VideoGeneratorView()
}
