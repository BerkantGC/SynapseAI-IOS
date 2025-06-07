//
//  HideKeyboardOnTapModifier.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 2.06.2025.
//

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                  to: nil, from: nil, for: nil)
                }
        )
    }
}
