//
//  Connection.swift
//  FitBro
//
//  Created by Riccardo Di Stefano on 09/02/24.
//

import Foundation
import CoreGraphics
import Vision
import UIKit

struct Connection {
    static let width: CGFloat = 10.0
    
    private let point1: CGPoint
    private let point2: CGPoint
    
    static let gradientColorSpace = CGColorSpace(name: CGColorSpace.sRGB)
    
    static let colors = [UIColor.systemGreen.cgColor,
                         UIColor.systemYellow.cgColor,
                         UIColor.systemOrange.cgColor,
                         UIColor.systemRed.cgColor,
                         UIColor.systemPurple.cgColor,
                         UIColor.systemBlue.cgColor
    ] as CFArray

    static let gradient = CGGradient(colorsSpace: gradientColorSpace,
                                     colors: colors,
                                     locations: [0, 0.2, 0.33, 0.5, 0.66, 0.8])!

    
    init(point1: CGPoint, point2: CGPoint) {
        self.point1 = point1
        self.point2 = point2
    }
    
    
    func drawToContext(_ context: CGContext,
                       applying transform: CGAffineTransform? = nil,
                       at scale: CGFloat = 1.0) {

        let start = point1.applying(transform ?? .identity)
        let end = point2.applying(transform ?? .identity)

        // Store the current graphics state.
        context.saveGState()

        // Restore the graphics state after the method finishes.
        defer { context.restoreGState() }

        // Set the line's thickness.
        context.setLineWidth(Connection.width * scale)

        // Draw the line.
        context.move(to: start)
        context.addLine(to: end)
        context.replacePathWithStrokedPath()
        context.clip()
        context.drawLinearGradient(Connection.gradient,
                                   start: start,
                                   end: end,
                                   options: .drawsAfterEndLocation)
    }
    
}
