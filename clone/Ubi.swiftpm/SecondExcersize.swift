//
//  ViewController.swift
//  FitBro
//
//  Created by Riccardo Di Stefano on 07/02/24.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI
import Combine
import Vision
import Lottie

class SecondExcersizeVC: UIViewController {
    
    var currentTest: Binding<Test>
    
    var imageView: UIImageView!
    var videoCapture: VideoCapture!
    var videoProcessingChain: VideoProcessingChain!

    var canRecognize = false
    var overlayView: UIView!
    var startRecognizeButton: UIButton!
    
    weak var timer: Timer?
    var startTime: Double = 0.0
    var time: Double = 0.0
    var result: Double = 0.0
    
    var finishTimes: [Double] = []
    
    init(test: Binding<Test>) {
        self.currentTest = test
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage()
        enableCamera()
        view.addSubview(imageView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.canRecognize = false
        self.videoCapture.isEnabled = false
    }
    
    private func enableCamera() {
        self.videoProcessingChain = VideoProcessingChain(self)
        self.videoCapture = VideoCapture(self.view, UIScreen.main.bounds)
        self.videoCapture.delegate = self
        self.videoCapture.isEnabled = true
        
        // Create an overlay view (in this case, a semi-transparent black view)
        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.frame = imageView.bounds
        overlayView.isUserInteractionEnabled = true  // Enable user interaction
        overlayView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        
        self.view.addSubview(overlayView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Excersize with your Right hand!"
        titleLabel.textColor = .systemGreen
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
                    titleLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
                    titleLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 100), // Adjust the constant for top spacing
                    titleLabel.widthAnchor.constraint(lessThanOrEqualTo: overlayView.widthAnchor, constant: -20) // Optional: Set a maximum width
                ])
        
        let tooltipLabel = UILabel()
        tooltipLabel.text = "Make sure that all the fingers are in frame and far apart from each other! You have to touch your fingers to your thumb, starting from the Index until the little finger while trying to keep a steady pace. Try to put the hand as close as possible to the camera!"
        
        tooltipLabel.textColor = .systemGreen
        tooltipLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        tooltipLabel.lineBreakMode = .byWordWrapping
        tooltipLabel.numberOfLines = 0
        
        tooltipLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(tooltipLabel)
        
        NSLayoutConstraint.activate([
                    tooltipLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
                    tooltipLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
                    tooltipLabel.widthAnchor.constraint(lessThanOrEqualTo: overlayView.widthAnchor, constant: -20) // Optional: Set a maximum width
                ])
        
        // Add a button to the overlay view
        startRecognizeButton = UIButton(type: .system)
        startRecognizeButton.setTitle("Start Recognize!", for: .normal)
        startRecognizeButton.setTitleColor(.white, for: .normal)
        startRecognizeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        startRecognizeButton.sizeToFit()
        
        // Position the button in the bottom right corner
        startRecognizeButton.frame.origin = CGPoint(x: overlayView.bounds.width - startRecognizeButton.bounds.width - 40, y: overlayView.bounds.height - startRecognizeButton.bounds.height - 40)
        
        // Add an action to the button
        startRecognizeButton.addTarget(self, action: #selector(canStartRecognize), for: .touchDown)
        
        overlayView.addSubview(startRecognizeButton)
        
        self.videoCapture.isEnabled = true
    }
    
    private func startTimer() {
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func advanceTimer(timer: Timer) {
        //Total time since timer started, in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
    }
    
    
    @objc private func canStartRecognize() {
        // Handle button tap
        print("Button tapped!")
        
        self.canRecognize = true
        // Remove the overlay when the button is tapped
        overlayView.removeFromSuperview()
    }
    
    private func drawPoints(_ pose: inout Pose, onto frame: CGImage) {
        
        // Create a default render format at a scale of 1:1.
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0
        
        // Create a renderer with the same size as the frame.
        let frameSize = CGSize(width: frame.width, height: frame.height)
        let poseRenderer = UIGraphicsImageRenderer(size: frameSize,
                                                   format: renderFormat)
        
        let frameWithPoints = poseRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext
            
            // Get the inverse of the current transform matrix (CTM).
            let inverse = cgContext.ctm.inverted()
            
            // Restore the Y-Axis by multiplying the CTM by its inverse to reset
            // the context's transform matrix to the identity.
            cgContext.concatenate(inverse)
            
            // Draw the camera image first as the background.
            let imageRectangle = CGRect(origin: .zero, size: frameSize)
            cgContext.draw(frame, in: imageRectangle)
            let pointTransform = CGAffineTransform(scaleX: frameSize.width,
                                                   y: frameSize.height)
            
            
            if(canRecognize) {checkConnection(&pose.landmarks)}
            //draw pose and current silhouette
            pose.drawToContext(cgContext, pointTransform)
            
            cgContext.saveGState()
            
        }
        
        DispatchQueue.main.async {
            guard self.imageView != nil else {return}
            guard self.imageView.image != nil else {return}
            
            self.imageView.image = frameWithPoints
        }
    }
    
    func checkConnection( _ marks: inout [Landmark]) {
        guard let thumbPosition = marks.first(where: {$0.jointName == .thumbTip}) else {
            print("returned first")
            return}
        
        
        guard let secondFinger = marks.first(where: {$0.jointName == checkMap.first}) else {
            print("returned second")
            return
        }
        
        /*
        guard let fingerIndex = marks.firstIndex(where: {$0.jointName == checkMap.first}) else {return}
        
        */
        let distance = thumbPosition.position.calculateDistance(point2: secondFinger.position)
        print("distance: \(distance) + \(String(describing: checkMap.first.debugDescription))")
        
        
        if (0.1...0.15).contains(distance) {
            if(time == 0.0) { startTimer() }
            
            self.finishTimes.append(time)
            
            self.checkMap.removeFirst()
        }
        
        if self.checkMap.isEmpty {
            checkFinish(marks)
        }
        return
    }
    
    private func checkFinish(_ marks: [Landmark]) {
        self.videoCapture.isEnabled = false
        self.imageView.removeFromSuperview()
        
        var timeSum = 0.0
        
        for t in finishTimes {
            timeSum += t
        }
        
        let avgtime = timeSum / 4
        self.result = avgtime
        
        self.currentTest.wrappedValue.secondTestResult = avgtime
        self.currentTest.wrappedValue.hasDoneSecondTest = true
        
        self.view.layer.sublayers?.removeAll()
        
        let string = self.formatToFirstTwoSignificantDigits(avgtime, decimalPlaces: 2)
        
        let label = UILabel()
        
        label.text = "Congratulations! You scored \(string)!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
                
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 250) // Adjust the "50" as needed
                ])
        
        
        let animationView: LottieAnimationView = LottieAnimationView(name: "checkMark")
        
        animationView.frame = view.frame
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.5
        animationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view.addSubview(animationView)
        animationView.play()
        
    }
    
    var checkMap: [VNHumanHandPoseObservation.JointName] = [
        .indexTip,
        .middleTip,
        .ringTip,
        .littleTip
    ]
    
    func formatToFirstTwoSignificantDigits(_ number: Double, decimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 2 + decimalPlaces

        if let formattedNumber = formatter.string(from: NSNumber(value: number)) {
            return formattedNumber
        } else {
            return "\(number)" // fallback to default string representation if formatting fails
        }
    }
}

extension SecondExcersizeVC: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        videoProcessingChain.upstreamPublisher = framePublisher
    }
}

extension SecondExcersizeVC: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain, _ pose: inout Pose, in frame: CGImage) {
        drawPoints(&pose, onto: frame)
    }
}

struct SecondExcersizeHVC: UIViewControllerRepresentable {
    @Binding var test: Test
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return SecondExcersizeVC(test: $test)
    }
    
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context){
        uiViewController.modalPresentationStyle = .formSheet
    }
}

#Preview(body: {
    SecondExcersizeHVC(test: .constant(Test()))
})
