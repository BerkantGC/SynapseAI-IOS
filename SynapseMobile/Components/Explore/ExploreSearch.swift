//
//  ExploreHeader.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

import SwiftUI
import Foundation

struct ExploreSearch : View {
    @Binding  var text: String;
    @Binding var isSearching: Bool;
    
    @FocusState private var isFocused: Bool
    var body: some View {
        HStack{
            TextField("Ara..", text: self.$text)
                .focused($isFocused)
                .onChange(of: isFocused) {
                    self.isSearching = !self.isSearching
                }
                .foregroundStyle(.text)
                .padding(.leading, 10)
                .padding(.vertical, 10)
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.trailing, 10)
        }
        .background(.ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }
}
