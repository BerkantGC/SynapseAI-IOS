//
//  PreferencesView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

import SwiftUICore
import SwiftUI

struct PreferencesView: View {
    @ObservedObject var viewModel: PreferencesViewModel = PreferencesViewModel()

    let genders = ["male", "female", "other"]

    var body: some View {
        ZStack {
            Background()
            
            VStack {

                Form {
                    Section(header: Text("Privacy")) {
                        Toggle("Private Account", isOn: $viewModel.isPrivate)
                    }
                    
                    Section(header: Text("Personal Information")) {
                        Picker("Gender", selection: $viewModel.gender) {
                            ForEach(genders, id: \.self) { gender in
                                Text(gender.capitalized)
                            }
                        }
                        
                        TextField("City", text: $viewModel.city)
                            .autocapitalization(.words)
                        
                        DatePicker("Birthday", selection: $viewModel.birthday, displayedComponents: .date)
                    }
                    
                    Section {
                        Button(action: {
                            Task {
                                await viewModel.savePrefereences()
                            }
                        }) {
                            Text("Save Preferences")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .scrollContentBackground(.hidden) // hides background on newer iOS
                .onAppear(){
                    Task {
                        await viewModel.getPreferences()
                    }
                }
                .toastView(toast: $viewModel.toast)
            }
        }
    }
}
