//
//  LottieView.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 7.06.2025.
//


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce
    var onComplete: (() -> Void)? = nil

    func makeUIView(context: Context) -> some UIView {
        let view = LottieAnimationView(name: filename)
        view.loopMode = loopMode
        view.play { finished in
            if finished {
                onComplete?()
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
