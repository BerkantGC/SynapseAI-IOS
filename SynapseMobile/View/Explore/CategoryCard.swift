//
//  Categories.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 15.11.2024.
//

import Foundation
import SwiftUI

struct CategoryCard : View {
    var category: Category
    
    init(category: Category) {
        self.category = category
    }
    
    var body: some View {
        VStack{
            Image(category.id)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .frame(width: .infinity, height: .infinity)
            Text(category.label)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }.frame(width: .infinity, height: 100)
    }
}
