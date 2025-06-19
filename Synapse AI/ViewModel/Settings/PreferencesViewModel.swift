//
//  Untitled.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

import Foundation

class PreferencesViewModel: ObservableObject {
    @Published var isPrivate: Bool = true
    @Published var gender: String = "male"
    @Published var city: String = ""
    @Published var birthday: Date = Date()
    @Published var toast: Toast? = nil
    @Published var bio: String = ""
    
    func getPreferences() async {
        await FetchService().executeRequest(url: "/profile/preferences", method: "GET", data: nil) { data, response, error in
            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(PreferencesModel.self, from: data)
                DispatchQueue.main.async {
                    self.isPrivate = decoded.is_private
                    self.gender = decoded.gender
                    self.city = decoded.city
                    self.bio = decoded.bio

                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    
                    if let date = formatter.date(from: decoded.birthday) {
                        self.birthday = date
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    func savePrefereences() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let payload: [String: Any] = [
            "is_private": isPrivate,
            "gender": gender,
            "city": city,
            "birthday": formatter.string(from: birthday), // ✅ fix here
            "bio": bio
        ]
        
        await FetchService().executeRequest(url: "/profile/update_preferences", method: "PUT", data: payload
        ) {
            data, response, error in
            
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                self.toast = Toast(style: .success, message: "Saved.", width: 160)
            }
        }
    }
}
