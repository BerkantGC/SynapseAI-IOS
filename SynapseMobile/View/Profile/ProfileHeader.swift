//
//  ProfileHeader.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct ProfileHeader : View {
    @EnvironmentObject var viewModel: ProfileViewModel;
    var profile: ProfileModel;
    
    @State var showFollows = false
    @State var selectedSegment: String = "followers"
    @State var selection: PhotosPickerItem?
    @State var selectedImageData: UIImage?
    @State private var isCropperPresented = false
    @State private var selectedUser: String?
    
    init(profile: ProfileModel) {
        self.profile = profile
    }
    
    var body: some View {
        VStack {
            HStack {
                PhotosPicker(selection: $selection, preferredItemEncoding: .automatic){
                    if let fetchedImage = profile.profile_picture{
                        AsyncImage(url: URL(string: fetchedImage)) { image in
                            image
                                .resizable()
                                .frame(width: 100, height: 100)
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .shadow(radius: 10)
                        } placeholder: {
                            Image("placeholder")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .shadow(radius: 10)
                        }.frame(width: 100, height: 100)
                    } else{
                        if selectedImageData != nil {
                            Image(uiImage: selectedImageData!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .shadow(radius: 10)
                            
                        }else{
                            
                            Image("placeholder")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .shadow(radius: 10)
                            
                        }
                    }
                }.onChange(of: selection) {
                    if let selection = selection {
                        Task{
                            if let image = try await selection.loadTransferable(type: Data.self){
                                self.selectedImageData = UIImage(data: image)
                                self.isCropperPresented.toggle()
                            }
                        }
                    }
                }
                
                
                Spacer()
                VStack(alignment: .leading) {
                    Text(profile.first_name! + " " + profile.last_name!)
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            HStack {
                
                Button(action: {
                    viewModel.getFollowers(status: FollowStatus.ACCEPTED)
                    self.selectedSegment = "followers"
                    showFollows.toggle()
                }) {
                    VStack {
                        Text("Takipçiler")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(profile.followers_count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.text)
                    }
                }
                
                Spacer()
                Button(action: {
                    viewModel.getFollowings(status: FollowStatus.ACCEPTED)
                    self.selectedSegment = "followings"
                    showFollows.toggle()
                }) {
                    VStack {
                        Text("Takip Edilenler")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(profile.followings_count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.text)
                    }
                }
            }
            .padding(.top, 20)
            .sheet(isPresented: $isCropperPresented) {
                CircularCropView(image: $selectedImageData)
            }
            .sheet(isPresented: $showFollows) {
                FollowsSheet(selectedSegment: $selectedSegment, selectedUser: $selectedUser)
            }
            .navigationDestination(item: $selectedUser) { user in
                ProfileView(username: user)
            }
        }.padding(.horizontal, 20)
    }
}
 
#Preview {
    Main()
}

