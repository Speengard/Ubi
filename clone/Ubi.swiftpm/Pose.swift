import Foundation
import Vision
import UIKit

struct Pose {
    typealias JointName = VNHumanHandPoseObservation.JointName
    
    var landmarks: [Landmark]!
    var connections: [Connection]!
    
    init(landmarks: [Landmark?]) {
        self.landmarks = landmarks.compactMap({e in return e})
    }
    
    
    func drawToContext(_ context: CGContext, _ transform: CGAffineTransform) {
        landmarks.forEach({ l in
            l.drawToContext(context, transform)
        })
    }
    
    
    init() {
        for joint in jointMap {
            self.landmarks.append(Landmark(jointName: joint, position: CGPoint(x: 0, y: 0)))
        }
    }
    
    public func setPositions(_ l: Landmark) {
        if var fundmark = self.landmarks.first(where: {$0.jointName == l.jointName}) {
            fundmark.position = l.position
        }else {
            return
        }
    }
    
    private let jointMap: [VNHumanHandPoseObservation.JointName] = [
        .indexTip,
        .middleTip,
        .ringTip,
        .littleTip,
        .thumbTip
    ]
    
}
