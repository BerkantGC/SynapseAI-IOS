//
//  VideoGeneratorView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 6.06.2025.
//

import SwiftUI

struct VideoGeneratorView: View {
    @ObservedObject var viewModel = UploadViewModel.shared
    
    @State private var prompt = ""
    
    @State private var isLoading = false
    @State private var showContinueButton = false
    
    var body: some View {
        
    }

    
}

#Preview {
    VideoGeneratorView()
}
