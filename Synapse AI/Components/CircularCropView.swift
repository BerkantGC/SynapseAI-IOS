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
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var isUploading: Bool = false

    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                ZStack {
                    // Dark background
                    Color.black
                        .edgesIgnoringSafeArea(.all)

                    // Image with gestures
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(scale)
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(0.5, min(5.0, lastScale * value))
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                        )

                    // Dark overlay with circular cutout
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .mask(
                            Rectangle()
                                .overlay(
                                    Circle()
                                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                                        .blendMode(.destinationOut)
                                )
                        )
                        .allowsHitTesting(false)

                    // Crop circle with gradient border
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.8), Color.white.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                        .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 0)
                        .allowsHitTesting(false)

                    // Top instruction and close button
                    VStack {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .allowsHitTesting(true)
                            .zIndex(1000)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scale = 1.0
                                    offset = .zero
                                    lastScale = 1.0
                                    lastOffset = .zero
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .allowsHitTesting(true)
                            .zIndex(1000)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .allowsHitTesting(true)
                        .zIndex(1000)
                        
                        Text("Move and Scale")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .allowsHitTesting(false)
                        
                        Text("Position your photo within the circle")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 4)
                            .allowsHitTesting(false)
                        
                        Spacer()
                        
                        // Bottom action area
                        VStack(spacing: 16) {
                            // Gesture hints
                            HStack(spacing: 24) {
                                HStack(spacing: 8) {
                                    Image(systemName: "hand.draw")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Drag")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.magnifyingglass")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Pinch to zoom")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.bottom, 8)
                            
                            // Action buttons
                            HStack(spacing: 16) {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 54)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 27))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 27)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                
                                Button(action: {
                                    if let croppedImage = cropImage(geometry: geometry) {
                                        uploadProfilePicture(croppedImage)
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        if isUploading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                        
                                        Text(isUploading ? "Uploading..." : "Set Photo")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(
                                        LinearGradient(
                                            colors: isUploading ?
                                                [Color.blue.opacity(0.6), Color.blue.opacity(0.4)] :
                                                [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 27))
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .disabled(isUploading)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom + 20, 40))
                    }
                }
            }
        }
    }

    private func cropImage(geometry: GeometryProxy) -> UIImage? {
        guard let image = image, let cgImage = image.cgImage else { return nil }

        let circleDiameter = geometry.size.width * 0.75
        let imageSize = image.size
        
        // Calculate the display size of the image after scaledToFill
        let imageAspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = geometry.size.width / geometry.size.height
        
        var displaySize: CGSize
        if imageAspectRatio > viewAspectRatio {
            // Image is wider - height fills the view
            displaySize = CGSize(width: geometry.size.height * imageAspectRatio, height: geometry.size.height)
        } else {
            // Image is taller - width fills the view
            displaySize = CGSize(width: geometry.size.width, height: geometry.size.width / imageAspectRatio)
        }
        
        // Apply the user's scale
        displaySize = CGSize(width: displaySize.width * scale, height: displaySize.height * scale)
        
        // Calculate the center of the displayed image
        let imageCenter = CGPoint(
            x: geometry.size.width / 2 + offset.width,
            y: geometry.size.height / 2 + offset.height
        )
        
        // Calculate the crop circle's center and radius in the view
        let cropCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let cropRadius = circleDiameter / 2
        
        // Convert to image coordinates
        let scaleToImage = imageSize.width / displaySize.width
        
        let cropCenterInImage = CGPoint(
            x: (cropCenter.x - imageCenter.x + displaySize.width / 2) * scaleToImage,
            y: (cropCenter.y - imageCenter.y + displaySize.height / 2) * scaleToImage
        )
        
        let cropRadiusInImage = cropRadius * scaleToImage
        
        // Create crop rect in image coordinates
        let cropRect = CGRect(
            x: cropCenterInImage.x - cropRadiusInImage,
            y: cropCenterInImage.y - cropRadiusInImage,
            width: cropRadiusInImage * 2,
            height: cropRadiusInImage * 2
        )
        
        // Ensure crop rect is within image bounds
        let clampedCropRect = cropRect.intersection(CGRect(origin: .zero, size: imageSize))
        
        guard !clampedCropRect.isNull, !clampedCropRect.isEmpty else { return nil }
        
        // Crop the image
        guard let croppedCGImage = cgImage.cropping(to: clampedCropRect) else { return nil }
        
        // Create circular image
        let outputSize = CGSize(width: cropRadiusInImage * 2, height: cropRadiusInImage * 2)
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        
        let circularImage = renderer.image { context in
            let bounds = CGRect(origin: .zero, size: outputSize)
            UIBezierPath(ovalIn: bounds).addClip()
            
            let croppedImage = UIImage(cgImage: croppedCGImage)
            croppedImage.draw(in: bounds)
        }
        
        return circularImage
    }
    
    private func uploadProfilePicture(_ croppedImage: UIImage) {
        guard let imageData = croppedImage.pngData() else {
            print("Failed to convert image to PNG data")
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isUploading = true
        }
        
        FetchService().buildFormData(
            url: "/profile/update-pp",
            method: "PUT",
            data: [:],
            fileKey: "file",
            fileData: imageData
        ) { data, response, error in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isUploading = false
                }
                
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    // You could show an error alert here
                    return
                }
                
                if data != nil {
                    print("Profile picture updated successfully")
                    self.image = croppedImage
                    
                    // Add a slight delay for better UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    print("No data received from server")
                }
            }
        }
    }
}
