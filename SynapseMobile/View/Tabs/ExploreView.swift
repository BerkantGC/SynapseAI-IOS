//
//  ExploreView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

import SwiftUI
import Foundation

struct ExploreView: View {
    @State var isSearching: Bool = false
    @State var query: String = ""
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
            
                SearchedView(searchText: query, isSearching: isSearching)
                    .searchable(text: $query,
                                isPresented: $isSearching,
                                prompt: "Ara..")
                    .onChange(of: query) {
                        viewModel.searchUsers(query: query)
                    }
                    .onSubmit {
                        //submitCurrentSearch()
                    }.environmentObject(viewModel)
                
                if !isSearching {
                    VStack(alignment: .leading) {
                        Text("Keşfet")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.text)
                            .padding(.horizontal, 10)
                        Spacer()
                        // Other content for "Explore" goes here
                    }
                }
                
            }
        }
    }
}

struct SearchedView: View {
    var searchText: String
    var isSearching: Bool

    @State  var isPresented = false
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject var viewModel: SearchViewModel

    var body: some View {
        if isSearching {
            ZStack{
                Background()
                VStack{
                    List{
                        ForEach(viewModel.users) { searchedUser in
                            UserSearchCard(user: searchedUser)
                        }
                    }
                    Spacer()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


#Preview {
    Main()
}
