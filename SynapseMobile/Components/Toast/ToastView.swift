//
//  ToastView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

import SwiftUI

struct ToastView: View {
  
  var style: ToastStyle
  var message: String
  var width = CGFloat.infinity
  var onCancelTapped: (() -> Void)
  
  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: style.iconFileName)
            .foregroundColor(style.themeColor)
        
      Text(message)
        .font(Font.caption)
        .foregroundColor(.primary)
      
      Spacer(minLength: 10)
      
      Button {
        onCancelTapped()
      } label: {
        Image(systemName: "xmark")
          .foregroundColor(style.themeColor)
      }
    }
    .padding(10)
    .frame(minWidth: 0, maxWidth: width)
    .background(.ultraThinMaterial)
    .padding(.horizontal, 16)
    .cornerRadius(8)
  }
}
