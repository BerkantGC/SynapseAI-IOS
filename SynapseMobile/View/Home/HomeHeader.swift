//
//  HomeHeader.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 11.11.2024.
//

import Foundation

import SwiftUI

struct HomeHeader: View {
    var body: some View {
        HStack {
            Button(action: {
                // Action
            }) {
                Image(systemName: "camera.metering.partial")
                    .foregroundStyle(.white)
                    .font(.title2)
            }.frame(width: 20, height:20)
            Image("logo")
                .resizable()
                .frame(width: 50, height: 50)
            Spacer()
            Button(action: {
                // Action
            }) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundStyle(.white)
            } .frame(width: 20, height: 20)
        }
        .padding(.horizontal)
    }
}
