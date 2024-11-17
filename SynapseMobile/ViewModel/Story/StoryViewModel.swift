//
//  StoryViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 16.11.2024.
//

import Foundation
import SwiftUI

class StoryViewModel: ObservableObject {
    @Published var stories: [StoryModel] = []
    
    func getUserStories(username: String){
        FetchService().executeRequest(url: "/stories/\(username)", method: "GET", data: nil) {
            data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([StoryModel].self, from: data)
                    DispatchQueue.main.async {
                        self.stories = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
    }
}
