//
//  UploadFormPage.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//
import SwiftUI

struct UploadFormPage: View {
    @State var image: UIImage
    @State var prompt: String?
    @State private var submittedPost: Post? = nil
    @State private var navigateToHome = false
    @State private var title: String = ""
    @State private var description: String = ""
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
                    // Header Section with Image and Prompt
                    VStack(spacing: 16) {
                        // Generated Image
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
                        
                        // Prompt Display
                        if let prompt = prompt {
                            VStack(spacing: 6) {
                                Text("Generated from prompt")
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
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Section Header
                        HStack {
                            Text("Post Details")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Title", systemImage: "textformat")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter a catchy title...", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        // Content Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description", systemImage: "doc.text")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("Share your thoughts, inspiration, or story behind this creation...", text: $content, axis: .vertical)
                                .lineLimit(4...8)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Submit Button
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
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                        .scaleEffect(isSubmitting ? 0.98 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isSubmitting)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .disabled(!isFormValid || isSubmitting)
                    
                    // Bottom spacing
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }.hideKeyboardOnTap()
            .scrollDismissesKeyboard(.interactively) // Dismiss on scroll
        }
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func submitForm() {
        guard isFormValid else { return }
        isSubmitting = true

        // Haptic
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()

        // Prepare form data
        let fields: [String: Any] = [
            "title": title,
            "content": content,
            "prompt": prompt ?? nil
        ]

        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            isSubmitting = false
            return
        }

        FetchService().buildFormData(
            url: "/posts/create-post",
            method: "POST",
            data: fields,
            fileKey: "image",
            fileData: imageData,
        ) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                        navigateToHome = true
                    } else {
                        print(httpResponse.statusCode)
                        let errorFeedback = UINotificationFeedbackGenerator()
                        errorFeedback.notificationOccurred(.error)
                    }
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

#Preview {
    NavigationView {
        UploadFormPage(image: .animal, prompt: "Flying Cat")
    }
}
