import SwiftUI

struct ImageGeneratorView: View {
    @ObservedObject var viewModel = UploadViewModel.shared
    
    @State private var prompt = ""
    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Background()

            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(width: .infinity, height: UIScreen.main.bounds.height / 2)
                        .overlay(
                            Group {
                                if let img = image {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFit()
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
                .padding(.horizontal)

                TextField("Enter prompt...", text: $prompt, axis: .vertical)
                    .lineLimit(3...6)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                Button(action: {
                    generateImage()
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

    private func generateImage() {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        Task {
            let generated = await viewModel.generateImage(prompt: prompt)
            withAnimation {
                image = generated
            }
            isLoading = false
        }
    }
}
