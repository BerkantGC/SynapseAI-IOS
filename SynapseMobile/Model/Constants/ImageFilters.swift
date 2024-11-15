//
//  ImageFilters.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12.11.2024.
//

import Foundation
import SwiftUI

enum FilterNames: String, CaseIterable, Identifiable {
    case chrome = "CIPhotoEffectChrome"
    case fade = "CIPhotoEffectFade"
    case instant = "CIPhotoEffectInstant"
    case mono = "CIPhotoEffectMono"
    case noir = "CIPhotoEffectNoir"
    case process = "CIPhotoEffectProcess"
    case tonal = "CIPhotoEffectTonal"
    case transfer = "CIPhotoEffectTransfer"
    case sepia = "CISepiaTone"
    case vignette = "CIVignette"
    case vignetteEffect = "CIVignetteEffect"
    
    var displayName: String {
        switch self {
        case .chrome:
            return "Chrome"
        case .fade:
            return "Fade"
        case .instant:
            return "Instant"
        case .mono:
            return "Mono"
        case .noir:
            return "Noir"
        case .process:
            return "Process"
        case .tonal:
            return "Tonal"
        case .transfer:
            return "Transfer"
        case .sepia:
            return "Sepia"
        case .vignette:
            return "Vignette"
        case .vignetteEffect:
            return "Vignette Effect"
        }
    }
    
   // Conforming to Identifiable
   var id: String { rawValue }
}
