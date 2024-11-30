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
        ScrollView(.horizontal) {
            HStack {
                ForEach(FilterNames.allCases){filter in
                    Button(action: {
                        // Apply filter
                        image = image?.applyFilter(filterName: filter)
                    }) {
                        Text(filter.displayName)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }.padding()
    }
}
