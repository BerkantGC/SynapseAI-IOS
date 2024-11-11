import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()

    init() {
        viewModel.loadPosts()
    }

    var body: some View {
        ZStack {
            Background()
            if viewModel.isLoading {
                ProgressView("Loading posts...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    Text("Gönderiler")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVStack{
                        ForEach(viewModel.posts) { post in
                            PostCard(post: post)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
    }
}
