//
//  Toast.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 1.06.2025.
//

struct Toast: Equatable {
  var style: ToastStyle
  var message: String
  var duration: Double = 3
  var width: Double = .infinity
}
