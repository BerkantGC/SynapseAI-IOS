import SwiftUI

enum MediaType {
    case image(UIImage)
    case video(URL)
}

struct UploadFormPage: View {
    @State var media: MediaType
    @State var prompt: String?
    @State private var submittedPost: Post? = nil
    @State private var navigateToHome = false
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Background()

            NavigationLink(destination: MyProfileView(), isActive: $navigateToHome) {
                EmptyView()
            }.hidden()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        mediaView

                        if let prompt = prompt {
                            VStack(spacing: 6) {
                                Text(isVideo ? "Generated video from prompt" : "Generated from prompt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(prompt)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                    }
                    .padding(.top, 8)

                    VStack(spacing: 20) {
                        HStack {
                            Text("Post Details")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Title", systemImage: "textformat")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            TextField("Enter a catchy title...", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description", systemImage: "doc.text")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            TextField(
                                "Share your thoughts, inspiration, or story behind this creation...",
                                text: $content,
                                axis: .vertical
                            )
                            .lineLimit(4...8)
                            .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal, 20)
                    }

                    Button(action: submitForm) {
                        HStack(spacing: 12) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16, weight: .semibold))
                            }

                            Text(isSubmitting ? "Publishing..." : "Publish Post")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: isFormValid ? [Color.accentColor, Color.accentColor.opacity(0.8)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(isFormValid ? .white : .secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(
                            color: isFormValid ? Color.accentColor.opacity(0.3) : .clear,
                            radius: 12, x: 0, y: 6
                        )
                        .scaleEffect(isSubmitting ? 0.98 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isSubmitting)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .disabled(!isFormValid || isSubmitting)

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .hideKeyboardOnTap()
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.large)
    }

    private var isVideo: Bool {
        if case .video = media { return true }
        return false
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private var mediaView: some View {
        switch media {
        case .image(let image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(3/4, contentMode: .fill)
                .frame(width: 200, height: 267)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        case .video(let videoURL):
            HLSPlayerView(url: videoURL.path, isDetail: true, isFilePath: true)
                .aspectRatio(3/4, contentMode: .fill)
                .frame(width: 200, height: 267)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private func submitForm() {
        guard isFormValid else { return }
        isSubmitting = true

        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()

        var fields: [String: Any] = [
            "title": title,
            "content": content
        ]

        if let prompt = prompt {
            fields["prompt"] = prompt
        }

        switch media {
        case .image(let image):
            submitImagePost(fields: fields, image: image)
        case .video(let videoURL):
            submitVideoPost(fields: fields, videoURL: videoURL)
        }
    }

    private func submitImagePost(fields: [String: Any], image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            isSubmitting = false
            return
        }

        FetchService().buildFormData(
            url: "/posts/create-post",
            method: "POST",
            data: fields,
            fileKey: "image",
            fileData: imageData
        ) { data, response, error in
            handleSubmissionResponse(data: data, response: response, error: error)
        }
    }

    private func submitVideoPost(fields: [String: Any], videoURL: URL) {
        print("🔗 Submitting to: \(videoURL)")
        guard let videoData = try? Data(contentsOf: videoURL) else {
            isSubmitting = false
            return
        }

        let fileName = videoURL.lastPathComponent
        let mimeType: String
        switch videoURL.pathExtension.lowercased() {
        case "mp4": mimeType = "video/mp4"
        case "mov": mimeType = "video/quicktime"
        default: mimeType = "application/octet-stream"
        }

        FetchService().buildFormData(
            url: "/posts/create-post",
            method: "POST",
            data: fields,
            fileKey: "video",
            fileData: videoData,
            fileName: fileName,
            mimeType: mimeType
        ) { data, response, error in
            handleSubmissionResponse(data: data, response: response, error: error)
        }
    }

    private func handleSubmissionResponse(data: Data?, response: URLResponse?, error: Error?) {
        DispatchQueue.main.async {
            isSubmitting = false

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    navigateToHome = true
                } else {
                    print(httpResponse.statusCode)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
