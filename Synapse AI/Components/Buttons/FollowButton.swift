//
//  FollowButton.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 6.06.2025.
//

import SwiftUI

struct FollowButton: View {
    @ObservedObject var profile: ProfileModel
    var isMe: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var onFollowStatusChange: (() -> Void)? = nil
    
    private var followStatusText: String {
        if isLoading {
            return "Loading..."
        }
        
        switch profile.follow_status {
        case .ACCEPTED:
            return "Following"
        case .PENDING:
            return "Requested"
        case .REJECTED:
            return "Follow"
        default:
            return "Follow"
        }
    }
    
    private var buttonColor: Color {
        switch profile.follow_status {
        case .ACCEPTED:
            return .gray.opacity(0.2)
        case .PENDING:
            return .orange
        default:
            return .blue
        }
    }
    
    private var textColor: Color {
        profile.follow_status == .ACCEPTED ? .primary : .white
    }
    
    var body: some View {
        if isMe {
            EmptyView()
        } else {
            Button {
                handleFollow()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(textColor)
                    }
                    
                    Text(followStatusText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(buttonColor)
                )
            }
            .disabled(isLoading)
            .animation(.easeInOut(duration: 0.2), value: profile.follow_status)
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
        }
    }
    
    private func handleFollow() {
        guard !isLoading else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isLoading = true
        }
        
        FetchService().executeRequest(
            url: "/profile/\(profile.user_id)/follow",
            method: "POST",
            data: nil
        ) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Error following user: \(error.localizedDescription)"
                    showError = true
                    return
                }
                
                guard data != nil else {
                    errorMessage = "No response data received"
                    showError = true
                    return
                }
                
                // Update follow status with animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    updateFollowStatus()
                }
            }
        }
    }
    
    private func updateFollowStatus() {
        switch profile.follow_status {
        case .ACCEPTED:
            profile.follow_status = nil
            profile.followers_count = max(0, profile.followers_count - 1)
            if profile.is_private {
                profile.visible.toggle()
            }
        case .PENDING:
            profile.follow_status = nil
        default:
            if profile.is_private {
                profile.follow_status = .PENDING
            } else {
                profile.follow_status = .ACCEPTED
                profile.followers_count += 1
            }
        }
        
        onFollowStatusChange?()
    }
}
