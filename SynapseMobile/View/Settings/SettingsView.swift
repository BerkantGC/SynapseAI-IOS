//
//  SettingsView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/7/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: LoginViewModel
    @Binding var isOpen: Bool
    @State var widthSize: CGFloat = .zero
    @State var isLogginOut: Bool = false
    
    var body: some View {
        GeometryReader{ proxy in
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.0))
                .overlay(
            VStack{
                Text("Ayarlar")
                    .font(.title)
                    .padding()
                Spacer()
                Button(action: {
                    viewModel.logout()
                    isLogginOut.toggle()
                    authViewModel.isLogged = false
                }, label: {
                    Text("Çıkış Yap")
                        .foregroundColor(.red)
                        .padding()
                })
            })
            .background(.thinMaterial)
            .frame(width: self.widthSize,
                   height: proxy.size.height,
                   alignment: .leading)
            .onAppear{
                withAnimation(.spring()){
                    self.widthSize = proxy.size.width
                }
            }
           
            .frame(width: proxy.size.width, alignment: .trailing)
        }
    }
}
