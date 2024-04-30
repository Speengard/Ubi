//
//  Landmark.swift
//  FitBro
//
//  Created by Riccardo Di Stefano on 08/02/24.
//

import Foundation
import Vision
import CoreGraphics
import UIKit

struct Landmark {
    
    var position: CGPoint
    var jointName: VNHumanHandPoseObservation.JointName
    var isChecked: Bool = false
    var checkedTime: Double = 0.0
    
    init(jointName: VNHumanHandPoseObservation.JointName, position: CGPoint) {
        self.jointName = jointName
        self.position = position
    }
    
    func drawToContext(_ context: CGContext, _ transform: CGAffineTransform? = nil) {
        
        self.isChecked ? context.setFillColor(UIColor.green.cgColor) : context.setFillColor(UIColor.white.cgColor)
        
        context.setStrokeColor(UIColor.darkGray.cgColor)
        
        var origin: CGPoint
        
        if transform != nil {
            origin = self.position.applying(transform!)
        }else {
            origin = self.position
        }
        
        context.fill(CGRect(x: origin.x, y: origin.y, width: 15, height: 15))
    }

}


