//
//  PostUploadView.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct PostUploadView: View {
    @State var image: Data?
    
    var body: some View{
        ZStack{
            Background()
            VStack{
                if let image = image {
                    MediaEditor(image: UIImage(data: image)!)
                }
            }
        }
    }
}
