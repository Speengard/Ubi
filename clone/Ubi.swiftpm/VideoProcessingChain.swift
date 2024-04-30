//
//  VideoProcessingChain.swift
//  FitBro
//
//  Created by Riccardo Di Stefano on 07/02/24.
//

import Foundation
import Vision
import Combine
import CoreImage

protocol VideoProcessingChainDelegate: AnyObject {
    func videoProcessingChain(_ chain: VideoProcessingChain, _ pose: inout Pose, in frame: CGImage)
}

struct VideoProcessingChain {
    init(_ delegate: VideoProcessingChainDelegate) {
        self.delegate = delegate
    }
    
    weak var delegate: VideoProcessingChainDelegate?
    
    private var frameProcessingChain: AnyCancellable?
    
    private let humanHandPoseRequest = VNDetectHumanHandPoseRequest()
    
    private let jointMap: [VNHumanHandPoseObservation.JointName] = [
        .indexTip,
        .middleTip,
        .ringTip,
        .littleTip,
        .thumbTip
    ]
    
    var upstreamPublisher: AnyPublisher<Frame, Never>! {
        didSet { createPublisher() }
    }
    
    private mutating func createPublisher() {
        guard upstreamPublisher != nil else { return }
        
        frameProcessingChain = upstreamPublisher
            .compactMap(frameToImage)
            .sink(receiveValue: findPointsInFrame)
    }
    
    private func frameToImage(_ frame: Frame) -> CGImage? {
        guard let imageBuffer = frame.imageBuffer else {
            print("The frame doesn't have an underlying image buffer.")
            return nil
        }
        
        // Create a Core Image context.
        let ciContext = CIContext(options: nil)
        
        // Create a Core Image image from the sample buffer.
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        // Generate a Core Graphics image from the Core Image image.
        guard let cgImage = ciContext.createCGImage(ciImage,
                                                    from: ciImage.extent) else {
            print("Unable to create an image from a frame.")
            return nil
        }
        
        return cgImage
    }
    
    private func findPointsInFrame(_ image: CGImage)  {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        
        do {
            try requestHandler.perform([humanHandPoseRequest])
            
        } catch {
            assertionFailure("error in performing request \(error)")
        }
        
        
        var bestObservation: [Landmark] = []
         
        if let first = humanHandPoseRequest.results?.first {
            for jointName in jointMap {
                do{
                    let point = try first.recognizedPoint(jointName)
                    bestObservation.append(Landmark(jointName: jointName, position: point.location))
                }catch{
                    continue
                }
            }
            
        }
        
        var pose = Pose(landmarks: bestObservation)
        
        DispatchQueue.main.async {
            self.delegate?.videoProcessingChain(self, &pose, in: image)
        }
    }
}
