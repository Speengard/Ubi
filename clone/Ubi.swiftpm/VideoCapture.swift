//
//  VideoCapture.swift
//  FitBro
//
//  Created by Riccardo Di Stefano on 07/02/24.
//

import Foundation
import Combine
import UIKit
import Vision
import AVFoundation

typealias Frame = CMSampleBuffer
typealias FramePublisher = AnyPublisher<Frame,Never>

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: FramePublisher)
}

class VideoCapture: NSObject {
    
    var isEnabled = true {
        didSet { isEnabled ? enableCaptureSession() : disableCaptureSession() }
    }
    
    private var permissionGranted: Bool = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue", qos: .userInitiated)
    var screenRect: CGRect! = nil
    
    public var view: UIView? = nil
    
    public var framePublisher: PassthroughSubject<Frame,Never>? = nil
    
    weak var delegate: VideoCaptureDelegate! {
        didSet { createFramePublisher() }
    }
    
    
    init(_ view: UIView,_ screenRect: CGRect) {
        self.view = view
        self.screenRect = screenRect
        super.init()
        self.checkPermissions()
        self.setupCaptureSession()
    }
    
    private func enableCaptureSession() {
        if !captureSession.isRunning { captureSession.startRunning() }
    }

    private func disableCaptureSession() {
        if captureSession.isRunning { captureSession.stopRunning() }
    }
    
    func setupCaptureSession() {
        if !permissionGranted { return }
        
        disableCaptureSession()

        guard isEnabled else {
            // Leave the camera disabled.
            return
        }

        // (Re)start the capture session after this method returns.
        defer { enableCaptureSession() }
        
        guard let videoInput = AVCaptureDeviceInput.createCameraInput(position: .back, frameRate: 30.0) else { return }
        let videoOutput = AVCaptureVideoDataOutput.withPixelFormatType(kCVPixelFormatType_32BGRA)
        
        videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        }else {
            assertionFailure("impossible adding the video input")
            return
        }
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }else {
            assertionFailure("impossible adding the video output")
            return
        }
        
    
        // This capture session must only have one connection.
        guard captureSession.connections.count == 1 else {
            let count = captureSession.connections.count
            print("The capture session has \(count) connections instead of 1.")
            return
        }
        
        // Configure the first, and only, connection.
        guard let connection = captureSession.connections.first else {
            print("Getting the first/only capture-session connection shouldn't fail.")
            return
        }
        
        captureSession.sessionPreset = .high
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        if #available(iOS 17.0, *) {
            connection.videoRotationAngle = 90.0
        } else {
            // Fallback on earlier versions
            connection.videoOrientation = .portrait
        }
        
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func createFramePublisher() {
        
        if !permissionGranted { return }
        
        let passThroughSubject = PassthroughSubject<Frame,Never>()
        
        framePublisher = passThroughSubject
        
        let genericFramePublisher = passThroughSubject.eraseToAnyPublisher()

        // Send the publisher to the `VideoCapture` instance's delegate.
        delegate.videoCapture(self, didCreate: genericFramePublisher)
    }
    
    
}

//MARK: PERMISSIONS
extension VideoCapture {
    func checkPermissions() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                permissionGranted = true
                break
            
            case .notDetermined:
                // request permission
                requestPermissions()
                break
                
            default:
                print("there's something wrong when checking camera permissions")
                permissionGranted = false
                break
        }
    }
    
    func requestPermissions() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {_ in
            self.permissionGranted = true
            self.sessionQueue.resume()
        })
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput frame: Frame, from connection: AVCaptureConnection) {
        framePublisher?.send(frame)
    }
}
