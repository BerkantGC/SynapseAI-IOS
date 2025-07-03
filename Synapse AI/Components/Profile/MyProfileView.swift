//
//  ProfileView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

struct MyProfileView: View {
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @State var isShowingSettings: Bool = false

    var body: some View {
        NavigationStack{
            ZStack {
                Background()

                ScrollView {
                    VStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.top, 20)
                        } else if viewModel.profile != nil {
                            ProfileHeader(isMe: true)
                                .environmentObject(viewModel)
                            //PurchaseView()
                        }
                        //ProfileStats()
                        PostsGrid(posts: viewModel.userPosts, pageTitle: viewModel.profile?.username ?? "")
                    }
                }
                
                if isShowingSettings {
                    SettingsView(isOpen: self.$isShowingSettings)
                        .toolbarVisibility(.hidden, for: .tabBar)
                }
            }.toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        isShowingSettings.toggle()
                    }){
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }.onAppear {
            viewModel.loadMyDetails()
        }
    }
}

struct PurchaseView: View {
    @StateObject var storeManager = StoreManager()

    var body: some View {
        Section(header: Text("Support & Upgrades")
        .font(.headline)
        .foregroundColor(.gray)
        .padding(.top)) {
            if !storeManager.products.isEmpty {
            VStack {
                ForEach(storeManager.products, id: \.productIdentifier) { product in
                    Button(action: {
                        storeManager.purchase(product: product)
                    }) {
                        Text("Buy \(product.localizedTitle) – \(product.priceLocale.currencySymbol ?? "")\(product.price)")
                    }
                    .padding()
                }
                }
            }
        }
    }
}


#Preview {
    Main()
}
