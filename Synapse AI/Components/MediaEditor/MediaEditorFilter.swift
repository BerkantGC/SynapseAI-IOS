//
//  MediaEditorFilter.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 13.11.2024.
//

import Foundation
import SwiftUI

struct MediaEditorFilter: View {
    @Binding var image: UIImage?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterNames.allCases) { filter in
                    Button(action: {
                        image = image?.applyFilter(filterName: filter)
                    }) {
                        Text(filter.displayName)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}
