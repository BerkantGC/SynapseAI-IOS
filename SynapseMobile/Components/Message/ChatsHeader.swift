//
//  ChatsHeader.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 30.11.2024.
//

import Foundation
import SwiftUI

struct ChatsHeader: View {
    @StateObject private var viewModel = SearchViewModel()
    @StateObject var socket = SocketManagerService.shared;
    @FocusState private var isSearching: Bool
    @Binding var isNavigating: Bool
    @Binding var selectedUser: Int?
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Kişi ara", text: $searchText)
                        .padding()
                        .focused($isSearching)
                        .onChange(of: searchText) {
                            viewModel.searchUsers(query: searchText)
                        }
                        .frame(height: 40)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                }
                
                if isSearching {
                    if viewModel.users.isEmpty {
                        Text("No users found")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(viewModel.users) { user in
                                    HStack {
                                        UserSearchCard(user: user) // Render user details
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                selectedUser = user.id
                                                socket.selectedSession = nil
                                                socket.messages.removeAll()
                                                isNavigating.toggle()
                                            }
                                            
                                    }
                                    .padding()
                                    .frame(width: .infinity)
                                }
                            }
                        }
                        .frame(width: .infinity)
                    }
                }
            }
        }
    }
}
