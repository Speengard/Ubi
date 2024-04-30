//
//  Extensions.swift
//  FitBro
//
//  Created by Riccardo Di Stefano on 08/02/24.
//

import Foundation
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Creates and configures a camera device input for VideoCapture.swift.
*/

import AVFoundation

extension AVCaptureDeviceInput {
    /// Creates a camera input set at the configuration's frame rate.
    /// - Tag: createCameraInput
    static func createCameraInput(position: AVCaptureDevice.Position,
                                  frameRate: Double) -> AVCaptureDeviceInput? {
        // Select the camera.
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            return nil
        }

        guard camera.configureFrameRate(frameRate) else { return nil }

        // Create an input from the camera.
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            // Device input is ready.
            return cameraInput
        } catch {
            print("Unable to create an input from the camera: \(error)")
            return nil
        }
    }
}

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Configures a capture device's frame rate range around a target frame rate.
*/

import AVFoundation
import Vision

extension AVCaptureDevice {
    /// Configures the capture device to use the best available frame rate range
    /// around the target frame rate.
    /// - Parameter target: A frame rate.
    /// - Returns: `true` if the method successfully configured the frame rate;
    /// otherwise `false`.
    /// - Tag: configureFrameRate
    func configureFrameRate(_ frameRate: Double) -> Bool {
        do { try lockForConfiguration() } catch {
            print("`AVCaptureDevice` wasn't unable to lock: \(error)")
            return false
        }

        // Release the configuration lock after returning from this method.
        defer { unlockForConfiguration() }

        // Sort the available frame rate ranges by descending `maxFrameRate`.
        let sortedRanges = activeFormat.videoSupportedFrameRateRanges.sorted {
            $0.maxFrameRate > $1.maxFrameRate
        }

        // Get the range with the highest `maxFrameRate`.
        guard let range = sortedRanges.first else {
            return false
        }

        // Ensure the target frame rate isn't below the range.
        guard frameRate >= range.minFrameRate else {
            return false
        }

        // Define the duration based on the target frame rate.
        let duration = CMTime(value: 1, timescale: CMTimeScale(frameRate))

        // If the target frame rate is within the range, use it as the minimum.
        let inRange = frameRate <= range.maxFrameRate
        activeVideoMinFrameDuration = inRange ? duration : range.minFrameDuration
        activeVideoMaxFrameDuration = range.maxFrameDuration

        return true
    }
}

extension AVCaptureVideoDataOutput {
    /// Creates a video data output with a pixel format.
    /// - Parameter pixelFormatType: The pixel format for the video output.
    /// - Tag: withPixelFormatType
    static func withPixelFormatType(_ pixelFormatType: OSType) -> AVCaptureVideoDataOutput {
        let videoDataOutput = AVCaptureVideoDataOutput()
        let validPixelTypes = videoDataOutput.availableVideoPixelFormatTypes

        guard validPixelTypes.contains(pixelFormatType) else {
            var errorMessage = "`AVCaptureVideoDataOutput` doesn't support "
            errorMessage += "pixel format type: \(pixelFormatType)\n"
            errorMessage += "Please use one of these instead:\n"

            for (index, pixelType) in validPixelTypes.enumerated() {
                var subscriptString = " availableVideoPixelFormatTypes"
                subscriptString += "[\(index)]"
                subscriptString += String(format: " (0x%08x)\n", pixelType)

                errorMessage += subscriptString
            }

            fatalError(errorMessage)
        }

        // Configure the output pixel type.
        let pixelTypeKey = String(kCVPixelBufferPixelFormatTypeKey)
        videoDataOutput.videoSettings = [pixelTypeKey: pixelFormatType]

        return videoDataOutput
    }
}


extension CGPoint {
    func distanceFrom(_ p:CGPoint) -> CGFloat {
        return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2))
    }
    
    func calculateDistance(point2: CGPoint) -> CGFloat {
        let deltaX = point2.x - x
        let deltaY = point2.y - y
        let distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2))
        return distance
    }
}
