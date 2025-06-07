//
//  SettingsViewModel.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/7/24.
//

import Foundation

class SettingsViewModel : ObservableObject {
    func logout(){
        KeychainService.instance.clear(forKey: "SESSION")
        SocketManagerService.shared.clear()
    }
}
