//
//  BookmarksViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

import Foundation

class BookmarksViewModel: ObservableObject {
    @Published var favorites: [Post] = []
    @Published var totalFavorites: Int = 0
    @Published var page: Int = 1
    
    func getFavorites() async {
        await FetchService().executeRequest(url: "/profile/favorites?page=\(page)", method: "GET", data: nil) { data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
                do{
                    let favoritesRes = try JSONDecoder().decode(FavoritesResponse.self, from: data)
                    
                    self.favorites = favoritesRes.favorites
                    self.totalFavorites = favoritesRes.total
                    self.page = favoritesRes.page
                } catch {
                    print("Error decoding JSON: \(error)")
                }
                
            }
        }
    }
}
