//
//  ExploreView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

import SwiftUI
import Foundation

struct ExploreView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State var isSearching: Bool = false
    @State var query: String = ""
    @State var selectedUser: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
            
                SearchedView(searchText: query,
                             isSearching: isSearching,
                             selectedUser: self.$selectedUser)
                    .searchable(text: $query,
                                isPresented: $isSearching,
                                prompt: "Search..")
                    .onChange(of: query) {
                        viewModel.searchUsers(query: query)
                    }
                    .onSubmit {
                        //submitCurrentSearch()
                    }.environmentObject(viewModel)
                
                if !isSearching {
                    ScrollView{
                        VStack(alignment: .leading, spacing: 0) {
                            CategoryList()
                            profileRecommendations()
                            exploreView()
                        }
                    }
                }
            }.onAppear(){
                Task {
                    await viewModel.fetchExplorePosts()
                    await viewModel.fetchFollowRecommendations()
                }
            }
            .navigationDestination(item: self.$selectedUser, destination: { user in
                ProfileView(username: user)
            })
        }
    }
    
    @ViewBuilder
    func exploreView() -> some View {
        Text("Explore")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.text)
            .padding(.horizontal, 10)
            .padding(.top)
        PostsGrid(posts: viewModel.posts, scrollDisabled: true)
    }
    
    @ViewBuilder
    func profileRecommendations () -> some View {
        Text("Profiles")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.text)
            .padding(.horizontal, 10)
            .padding(.vertical)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.recommendations) { recommendedProfile in
                    HStack(alignment: .center) {
                        ProfileImageView(imageData: nil, imageUrl: recommendedProfile.profile_picture, size: 30)
                        Text(recommendedProfile.fullname ?? "")
                        Image(systemName: "star.circle")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(.ultraThinMaterial))
                }
            }.padding(.horizontal)
        }
    }
}

struct CategoryList: View {
    var categoryList: [Category] = Category.allCases;
    
    var body: some View {
        Text("Categories")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.text)
            .padding(.horizontal, 10)
            .padding(.vertical)
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(0...(categoryList.count - 1), id: \.self){ index in
                    CategoryCard(category: categoryList[index])
                }
            }.padding(.horizontal)
        }
    }
}

struct SearchedView: View {
    var searchText: String
    var isSearching: Bool

    @State  var isPresented = false
    @Binding var selectedUser: String?
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject var viewModel: SearchViewModel
    
    var body: some View {
        if isSearching {
            GeometryReader{ proxy in
                RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.0))
                .overlay(
                    ScrollView{
                        VStack{
                            Text("Results")
                                .font(.title)
                                .padding()
                            ForEach(viewModel.users) { searchedUser in
                                UserSearchCard(user: searchedUser)
                                    .frame(width: proxy.size.width - 20)
                                    .onTapGesture {
                                        selectedUser = searchedUser.username
                                    }
                            }
                            Spacer()
                        }
                    }
                )
                .background(.ultraThinMaterial)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            }
        }
    }
}

#Preview{
    ExploreView()
}
