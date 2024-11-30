//
//  ImagePicker.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 23.11.2024.
//

import Foundation
import SwiftUI
struct CircularCropView: View {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                ZStack {
                    Color.black.opacity(0.8)
                        .edgesIgnoringSafeArea(.all)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(scale)
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .gesture(
                            DragGesture().onChanged { value in
                                offset = CGSize(
                                    width: value.translation.width,
                                    height: value.translation.height
                                )
                            }
                        )
                        .gesture(
                            MagnificationGesture().onChanged { value in
                                scale = max(1.0, value)
                            }
                        )

                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                        .allowsHitTesting(false)

                    VStack {
                        Spacer()
                        Button("Crop") {
                            cropImage(geometry: geometry)
                            FetchService().buildFormData(url: "/profile/update-pp",
                                                         method: "PUT",
                                                         data: [:],
                                                         fileKey: "file",
                                                         fileData: image.pngData()!,
                                                         completion: { data, response, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
                                if let data = data {
                                    do {
                                        print("Profile picture updated")
                                        self.presentationMode.wrappedValue.dismiss()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            })
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func cropImage(geometry: GeometryProxy) {
        guard let image = image, let cgImage = image.cgImage else { return }

        // Calculate the size of the circle on screen
        let circleDiameter = geometry.size.width * 0.8
        let circleRadius = circleDiameter / 2

        // The frame of the crop circle in the GeometryReader's coordinate system
        let cropRectInView = CGRect(
            x: (geometry.size.width - circleDiameter) / 2 - offset.width,
            y: (geometry.size.height - circleDiameter) / 2 - offset.height,
            width: circleDiameter,
            height: circleDiameter
        )

        // Scale factor: Map the view's frame back to the image's resolution
        let imageScale = max(image.size.width / geometry.size.width, image.size.height / geometry.size.height)

        // Map cropRectInView to the image's coordinate system
        let cropRectInImage = CGRect(
            x: cropRectInView.origin.x * imageScale,
            y: cropRectInView.origin.y * imageScale,
            width: cropRectInView.size.width * imageScale,
            height: cropRectInView.size.height * imageScale
        )

        // Perform the cropping on the image
        if let croppedCGImage = cgImage.cropping(to: cropRectInImage) {
            let croppedImage = UIImage(cgImage: croppedCGImage)

            // Apply circular mask to the cropped image
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: circleDiameter, height: circleDiameter))
            let circularImage = renderer.image { context in
                UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: circleDiameter, height: circleDiameter))).addClip()
                croppedImage.draw(in: CGRect(origin: .zero, size: CGSize(width: circleDiameter, height: circleDiameter)))
            }

            // Update the image with the cropped circular version
            self.image = circularImage
        }
    }
}
