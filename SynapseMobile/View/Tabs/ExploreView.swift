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
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
            
                SearchedView(searchText: query, isSearching: isSearching)
                    .searchable(text: $query,
                                isPresented: $isSearching,
                                prompt: "Ara..")
                    .onSubmit {
                        //submitCurrentSearch()
                    }
                
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

    let items = ["a", "b", "c"]
    var filteredItems: [String] { items.filter { $0 == searchText.lowercased() } }


    @State  var isPresented = false
    @Environment(\.dismissSearch) private var dismissSearch


    var body: some View {
        if isSearching {
            ZStack{
                Background()
                VStack{
                    Spacer()
                    if let item = filteredItems.first {
                        Button("Details about \(item)") {
                            isPresented = true
                        }
                        .sheet(isPresented: $isPresented) {
                            Text("Details about \(item)")
                        }
                    }
                    Spacer()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


#Preview {
    ExploreView()
}
