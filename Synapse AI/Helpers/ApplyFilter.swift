//
//  ApplyFilter.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

extension UIImage {
    func applyFilter(filterName: FilterNames) -> UIImage {
        let context = CIContext(options: nil)
        guard let ciImage = CIImage(image: self) else { return self }
        
        print("Applying filter: \(filterName.rawValue)")
        let filter = CIFilter(name: filterName.rawValue)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return self // Return original image if filtering fails
    }
}
