import Foundation
import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: LoginViewModel
    @Binding var isOpen: Bool
    @State private var widthSize: CGFloat = .zero
    @State private var isLogginOut: Bool = false
    @State private var showSections: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.0))
                .overlay(
                    VStack {
                        Text("Settings")
                            .font(.title)
                            .padding()
                        
                        if showSections {
                            // Update Preferences
                            NavigationLink(destination: BookmarksView()) {
                                HStack {
                                    Image(systemName: "bookmark.fill")
                                        .foregroundColor(.yellow)
                                    Text("Favorites")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }

                            // Update Preferences
                            NavigationLink(destination: PreferencesView()) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.blue)
                                    Text("Update Preferences")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }
                        }

                        Spacer()

                        // Logout
                        Button(action: {
                            viewModel.logout()
                            isLogginOut.toggle()
                            authViewModel.isLogged = false
                        }) {
                            Text("Logout")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .opacity(widthSize == 0 ? 0 : 1) // hide content before animation
                    .animation(.easeInOut, value: showSections)
                    .padding()
                )
                .background(.thinMaterial)
                .frame(width: self.widthSize, height: proxy.size.height, alignment: .leading)
                .onAppear {
                    withAnimation(.spring()) {
                        self.widthSize = proxy.size.width
                    }

                    // Show sections after animation ends (e.g., 0.4s delay)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation {
                            showSections = true
                        }
                    }
                }
                .frame(width: proxy.size.width, alignment: .trailing)
        }
    }
}
