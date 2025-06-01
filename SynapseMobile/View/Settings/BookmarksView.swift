//
//  BookmarksView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

import SwiftUI
import Foundation

struct BookmarksView: View {
    @ObservedObject var viewModel: BookmarksViewModel = BookmarksViewModel();
    
    var body: some View {
        ZStack {
            Background()
            
            ScrollView {
                VStack{
                    PostsGrid(posts: viewModel.favorites, scrollDisabled: true, pageTitle: "Favorites")
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .onAppear() {
            Task{
                await viewModel.getFavorites()
            }
        }
    }
}

#Preview {
    Main()
}
