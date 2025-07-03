//
//  CameraManager.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 7.06.2025.
//
import Foundation
import AVFoundation
import UIKit
import MediaPipeTasksVision

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var faceLandmarker: FaceLandmarker?
    var onSmileDetected: (() -> Void)?
    private var didTriggerUnlock = false
    @Published var smileDetected = false
    
    // Gülüş stabilitesi için
    private var smileScoreHistory: [Float] = []
    private let historySize = 10
    private var consecutiveSmileFrames = 0
    private let requiredConsecutiveFrames = 5
    private var lastSmileTime: Date?
    private let smileCooldown: TimeInterval = 2.0
    
    override init() {
        super.init()
        setup()
        initFaceLandmarker()
    }
    
    func setup() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.devices(for: .video).first(where: { $0.position == .front }),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return
        }
        
        session.addInput(input)
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
            session.addOutput(videoOutput)
        }
        session.commitConfiguration()
    }
    
    func startSession() {
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func resetSmileDetection() {
        didTriggerUnlock = false
        smileScoreHistory.removeAll()
        consecutiveSmileFrames = 0
        lastSmileTime = nil
        DispatchQueue.main.async {
            self.smileDetected = false
        }
    }
    
    func initFaceLandmarker() {
        guard let modelPath = Bundle.main.path(forResource: "face_landmarker", ofType: "task") else { return }
        let options = FaceLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.outputFaceBlendshapes = true
        options.runningMode = .video
        faceLandmarker = try? FaceLandmarker(options: options)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: buffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        detectSmile(from: image)
    }
    
    private func detectSmile(from image: UIImage) {
        guard !didTriggerUnlock,
              let mpImage = try? MPImage(uiImage: image),
              let faceLandmarker = faceLandmarker,
              let result = try? faceLandmarker.detect(videoFrame: mpImage, timestampInMilliseconds: Int(Date().timeIntervalSince1970 * 1000)),
              let blendShapes = result.faceBlendshapes.first else {
            DispatchQueue.main.async {
                self.smileDetected = false
            }
            return
        }
        
        // Get all the blendshaped for smile
        let leftSmile = blendShapes.categories.first(where: { $0.categoryName == "mouthSmileLeft" })?.score ?? 0
        let rightSmile = blendShapes.categories.first(where: { $0.categoryName == "mouthSmileRight" })?.score ?? 0
        let cheekSquintLeft = blendShapes.categories.first(where: { $0.categoryName == "cheekSquintLeft" })?.score ?? 0
        let cheekSquintRight = blendShapes.categories.first(where: { $0.categoryName == "cheekSquintRight" })?.score ?? 0
        let eyeSquintLeft = blendShapes.categories.first(where: { $0.categoryName == "eyeSquintLeft" })?.score ?? 0
        let eyeSquintRight = blendShapes.categories.first(where: { $0.categoryName == "eyeSquintRight" })?.score ?? 0
        let mouthPucker = blendShapes.categories.first(where: { $0.categoryName == "mouthPucker" })?.score ?? 0
        let jawOpen = blendShapes.categories.first(where: { $0.categoryName == "jawOpen" })?.score ?? 0
        
        // Calculate realistic smile score
        let smileScore = calculateRealisticSmileScore(
            leftSmile: leftSmile,
            rightSmile: rightSmile,
            cheekSquintLeft: cheekSquintLeft,
            cheekSquintRight: cheekSquintRight,
            eyeSquintLeft: eyeSquintLeft,
            eyeSquintRight: eyeSquintRight,
            mouthPucker: mouthPucker,
            jawOpen: jawOpen
        )
        
        // Add score to history
        smileScoreHistory.append(smileScore)
        if smileScoreHistory.count > historySize {
            smileScoreHistory.removeFirst()
        }
        
        // Get all the scores average (Stability)
        let averageSmileScore = smileScoreHistory.reduce(0, +) / Float(smileScoreHistory.count)
        
        
        let dynamicThreshold = calculateDynamicThreshold()
        let isSmiling = averageSmileScore > dynamicThreshold
        
        // Consecutive frame control
        if isSmiling {
            consecutiveSmileFrames += 1
        } else {
            consecutiveSmileFrames = 0
        }
        
        // Cooldown control
        let currentTime = Date()
        let canTriggerSmile = lastSmileTime == nil || currentTime.timeIntervalSince(lastSmileTime!) > smileCooldown
        
        // is Smile Detected?
        let finalSmileDetected = consecutiveSmileFrames >= requiredConsecutiveFrames && canTriggerSmile
        
        DispatchQueue.main.async {
            self.smileDetected = finalSmileDetected
            if finalSmileDetected {
                self.didTriggerUnlock = true
                self.lastSmileTime = currentTime
                self.onSmileDetected?()
            }
        }
    }
    
    private func calculateRealisticSmileScore(
        leftSmile: Float,
        rightSmile: Float,
        cheekSquintLeft: Float,
        cheekSquintRight: Float,
        eyeSquintLeft: Float,
        eyeSquintRight: Float,
        mouthPucker: Float,
        jawOpen: Float
    ) -> Float {
        let baseSmileScore = (leftSmile + rightSmile) / 2
        let eyeSquintScore = (eyeSquintLeft + eyeSquintRight) / 2
        let cheekSquintScore = (cheekSquintLeft + cheekSquintRight) / 2
        let asymmetryPenalty = abs(leftSmile - rightSmile)
        let puckerPenalty = mouthPucker
        let jawOpenPenalty = jawOpen > 0.3 ? jawOpen * 0.5 : 0
        
        // Weighted score hesaplama
        var realisticScore = baseSmileScore * 0.6 // Temel ağırlık
        realisticScore += eyeSquintScore * 0.3 // Göz kısılması
        realisticScore += cheekSquintScore * 0.2 // Yanak kısılması
        realisticScore -= asymmetryPenalty * 0.3 // Asimetri cezası
        realisticScore -= puckerPenalty * 0.4 // Büzülme cezası
        realisticScore -= jawOpenPenalty // Ağız açma cezası
        
        return max(0, min(1, realisticScore))
    }
    
    private func calculateDynamicThreshold() -> Float {
        // Dynamic Threshold base
        let baseThreshold: Float = 0.4
        
        // If there's any history adjust accordingly
        if smileScoreHistory.count >= 5 {
            let recentAverage = Array(smileScoreHistory.suffix(5)).reduce(0, +) / 5
            let standardDeviation = calculateStandardDeviation(scores: smileScoreHistory)
            
            // If there is a lot of variability, raise the threshold
            if standardDeviation > 0.15 {
                return baseThreshold + 0.1
            }
            
            // If there are consistently low scores, lower the threshold
            if recentAverage < 0.2 {
                return baseThreshold - 0.05
            }
        }
        
        return baseThreshold
    }
    
    private func calculateStandardDeviation(scores: [Float]) -> Float {
        guard scores.count > 1 else { return 0 }
        
        let mean = scores.reduce(0, +) / Float(scores.count)
        let squaredDifferences = scores.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Float(scores.count - 1)
        
        return sqrt(variance)
    }
}
