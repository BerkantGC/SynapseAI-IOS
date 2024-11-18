//
//  CommentView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 17.11.2024.
//

import Foundation
import SwiftUI

struct CommentView : View {
    @StateObject private var viewModel = CommentViewModel()
    var postId: Int
    
    var body: some View{
        VStack{
            Text("Yorumlar")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            List{
                ForEach(viewModel.comments){ comment in
                    Text(comment.content!)
                }
            }
        }.onAppear{
            viewModel.loadComments(postId: postId)
        }
    }
}
