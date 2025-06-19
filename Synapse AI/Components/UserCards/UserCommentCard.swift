import Foundation
import SwiftUI

struct UserCommentCard: View {
    @State var comment: CommentModel
    var onReply: (() -> Void)? = nil

    @State private var expandedAnswers: [AnswerModel] = []
    @State private var hasLoadedAllReplies = false
    @State private var isLoadingReplies = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main comment
            commentView(comment, isAnswer: false)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

            // Replies section
            if hasReplies {
                VStack(alignment: .leading, spacing: 0) {
                    // Top connection to main comment
                    HStack {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 2, height: 12)
                            .padding(.leading, 36)
                        Spacer()
                    }
                    
                    // Replies with continuous vertical line
                    ZStack(alignment: .topLeading) {
                        // Continuous vertical line - extends to bottom of last reply's profile picture
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 2, height: calculateVerticalLineHeight())
                                .padding(.leading, 36)
                        }
                        
                        // Replies content
                        VStack(alignment: .leading, spacing: 0) {
                            // First reply preview (if not expanded)
                            if !hasLoadedAllReplies, let topAnswer = comment.answers.first {
                                replyView(topAnswer, isLast: shouldShowLoadMore ? false : true)
                            }

                            // Expanded replies
                            ForEach(Array(expandedAnswers.enumerated()), id: \.element.id) { index, answer in
                                replyView(answer, isLast: index == expandedAnswers.count - 1 && hasLoadedAllReplies)
                            }

                            // Load more button
                            if !hasLoadedAllReplies, let count = comment.answers_count, count > 1 {
                                loadMoreButton(count: count)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var shouldShowLoadMore: Bool {
        !hasLoadedAllReplies && (comment.answers_count ?? 0) > 1
    }
    
    private func calculateVerticalLineHeight() -> CGFloat {
        let profilePictureSize: CGFloat = 32
        let replyPadding: CGFloat = 8
        let replySpacing: CGFloat = 4
        
        var totalHeight: CGFloat = 0
        
        // Height for first reply preview (if shown)
        if !hasLoadedAllReplies && comment.answers.first != nil {
            totalHeight += profilePictureSize + (replyPadding * 2) + replySpacing
        }
        
        // Height for expanded replies
        if hasLoadedAllReplies {
            totalHeight += CGFloat(expandedAnswers.count) * (profilePictureSize + (replyPadding * 2) + replySpacing)
        }
        
        // Add some extra height to reach the bottom of the last profile picture
        return (totalHeight > 0 && comment.answers.first == nil) ? totalHeight - replySpacing + (profilePictureSize / 2) : (replyPadding*2 + replySpacing)
    }
    
    private var hasReplies: Bool {
        (comment.answers_count ?? 0) > 0 || !expandedAnswers.isEmpty
    }
    
    @ViewBuilder
    private func replyView(_ answer: AnswerModel, isLast: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Horizontal connector to vertical line
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: 20) // Space to center the horizontal line with profile picture
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 20, height: 2)
            }
            .padding(.leading, 36)
            
            commentView(answer, isAnswer: true)
                .padding(.leading, 8)
                .padding(.trailing, 16)
                .padding(.vertical, 8)
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private func loadMoreButton(count: Int) -> some View {
        HStack {
            // Horizontal connector to vertical line
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: 20, height: 2)
                .padding(.leading, 36)
            
            Button {
                loadAnswers()
            } label: {
                HStack(spacing: 6) {
                    if isLoadingReplies {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                    }
                    
                    Text(isLoadingReplies ? "Loading..." : "See all \(count) replies")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 8)
            .padding(.bottom, 8)
            
            Spacer()
        }
    }

    func loadAnswers() {
        guard !isLoadingReplies else { return }
        isLoadingReplies = true

        FetchService().executeRequest(
            url: "/comments/\(comment.id)/answers",
            method: "GET",
            data: nil
        ) { data, response, error in
            DispatchQueue.main.async {
                isLoadingReplies = false
                guard let data = data else { return }
                do {
                    let fetchedAnswers = try JSONDecoder().decode([AnswerModel].self, from: data)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        expandedAnswers = fetchedAnswers
                        hasLoadedAllReplies = true
                    }
                } catch {
                    print("Failed to decode answers: \(error)")
                }
            }
        }
    }
    
    private func toggleLike(for item: any DisplayableComment, isAnswer: Bool) {
       guard !isLoadingReplies else { return }
       isLoadingReplies = true

       let endpoint = isAnswer ? "/answers/\(item.id)/like" : "/comments/\(item.id)/like"
       
       FetchService().executeRequest(
           url: endpoint,
           method: "POST",
           data: nil
       ) { data, response, error in
           DispatchQueue.main.async {
               isLoadingReplies = false
               
               if let error = error {
                   print("Failed to toggle like: \(error)")
                   return
               }
               
               guard data != nil else {
                   print("No response data")
                   return
               }
               
               // Update the appropriate item's like status
               if isAnswer {
                   // Find and update the answer in expandedAnswers
                   if let index = expandedAnswers.firstIndex(where: { $0.id == item.id }) {
                       expandedAnswers[index].liked.toggle()
                       expandedAnswers[index].likes_count += expandedAnswers[index].liked ? 1 : -1
                   }
               } else {
                   // Update the main comment
                   comment.liked.toggle()
                   comment.likes_count += comment.liked ? 1 : -1
               }
           }
       }
   }

    @ViewBuilder
    func commentView<T: DisplayableComment>(_ data: T, isAnswer: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ProfileImageView(imageData: nil,
                                 imageUrl: data.profile_picture,
                                 size: isAnswer ? 32 : 40)
                    .overlay(
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    // User info and timestamp
                    HStack(alignment: .center, spacing: 4) {
                        Text(data.user)
                            .font(isAnswer ? .subheadline : .headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        if let created = formattedTime(data.created_at) {
                            Circle()
                                .fill(Color(.systemGray3))
                                .frame(width: 3, height: 3)
                            
                            Text(created)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }

                    // Comment content
                    Text(data.content)
                        .font(isAnswer ? .subheadline : .body)
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    // Action buttons
                    HStack(spacing: 20) {
                        // Like button
                        Button {
                            toggleLike(for: data, isAnswer: isAnswer)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: data.liked ? "heart.fill" : "heart")
                                    .font(.caption)
                                    .foregroundColor(data.liked ? .red : .secondary)
                                
                                Text(formatLikes(data.likes_count))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                        )

                        // Reply button (only for main comments)
                        if data is CommentModel {
                            Button {
                                onReply?()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrowshape.turn.up.left")
                                        .font(.caption)
                                    Text("Reply")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    func formatLikes(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        } else {
            return "\(count)"
        }
    }

    func formattedTime(_ dateString: String?) -> String? {
        guard let dateString,
              let date = Date.stringToDate(dateString) else { return nil }

        let minutes = Int(Date().timeIntervalSince(date) / 60)
        if minutes < 1 { return "now" }
        else if minutes < 60 { return "\(minutes)m" }
        else if minutes < 1440 { return "\(minutes / 60)h" }
        else { return "\(minutes / 1440)d" }
    }
}
