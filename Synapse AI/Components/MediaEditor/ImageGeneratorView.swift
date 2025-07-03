import SwiftUI
import Photos

struct ImageGeneratorView: View {
    @ObservedObject var viewModel = UploadViewModel.shared
    
    @State private var prompt = ""
    @State private var image: UIImage?
    @State private var videoURL: URL? // Changed from String to URL
    @State private var isLoading = false
    @State private var showContinueButton = false
    @State private var selection: String = "image"
    @State private var showSaveSuccess = false
    @State private var showSaveError = false

    var body: some View {
        ZStack {
            Background()

            VStack {
                Picker(selection: $selection, label: Text("Media Picker")) {
                    Text("Image").tag("image")
                    Text("Video").tag("video")
                }
                .pickerStyle(.segmented)

                if selection == "image" {
                    imageGenerator().padding(.top)
                } else {
                    videoGenerator().padding(.top)
                }
            }
        }
        .navigationTitle("Generate")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {} label: { Color.clear }
            }
        }
        .alert("Saved to Photos", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) {}
        }
        .alert("Failed to Save", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        }
    }

    func imageGenerator() -> some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Group {
                            if let img = image {
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(3/4, contentMode: .fit)
                                    .cornerRadius(12)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.3), value: image)
                            } else {
                                Text("Preview")
                                    .font(.title2.bold())
                                    .foregroundColor(.gray)
                            }
                        }
                    )
            }
            .hideKeyboardOnTap()
            .padding(.horizontal)

            TextField("Enter prompt...", text: $prompt, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)

            Button(action: generateImage) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    } else {
                        Image(systemName: "wand.and.stars")
                        Text("Generate").fontWeight(.semibold)
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

            if showContinueButton && image != nil {
                HStack {
                    Spacer()

                    Button(action: saveImageToPhotos) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                    }

                    NavigationLink(destination: UploadFormPage(media: .image(image!), prompt: prompt)) {
                        HStack(spacing: 6) {
                            Text("Next")
                            Image(systemName: "arrow.right")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.indigo)
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    .padding(.leading, 4)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
    }

    func videoGenerator() -> some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Group {
                            if let video = videoURL {
                                // Use the URL path for the player
                                HLSPlayerView(url: video.path, isDetail: true, isFilePath: true)
                                    .cornerRadius(12)
                            } else {
                                Text("Preview")
                                    .font(.title2.bold())
                                    .foregroundColor(.gray)
                            }
                        }
                    )
            }
            .hideKeyboardOnTap()
            .padding(.horizontal)

            TextField("Enter prompt...", text: $prompt, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)

            Button(action: generateVideo) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    } else {
                        Image(systemName: "wand.and.stars")
                        Text("Generate").fontWeight(.semibold)
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

                    Button(action: saveVideoToPhotos) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                    }

                    // Now passing the proper URL object
                    NavigationLink(destination: UploadFormPage(media: .video(videoURL!), prompt: prompt)) {
                        HStack(spacing: 6) {
                            Text("Next")
                            Image(systemName: "arrow.right")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.indigo)
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    .padding(.leading, 4)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
    }

    private func generateImage() {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        Task {
            let generated = await viewModel.generateImage(prompt: prompt)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                image = generated
                showContinueButton = true
            }
            isLoading = false
        }
    }

    private func generateVideo() {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        Task {
            let generatedPath = await viewModel.generateVideo(prompt: prompt)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                // Convert the string path to a proper file URL
                if let path = generatedPath {
                    videoURL = URL(fileURLWithPath: path)
                }
                showContinueButton = true
            }
            isLoading = false
        }
    }

    // MARK: - Save helpers
    private func saveImageToPhotos() {
        guard let img = image else { return }

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                showSaveError = true
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: img)
            }) { success, _ in
                DispatchQueue.main.async {
                    showSaveSuccess = success
                    showSaveError   = !success
                }
            }
        }
    }

    private func saveVideoToPhotos() {
        guard let localURL = videoURL else {
            showSaveError = true
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                showSaveError = true
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localURL)
            }) { success, _ in
                DispatchQueue.main.async {
                    showSaveSuccess = success
                    showSaveError   = !success
                }
            }
        }
    }
}
