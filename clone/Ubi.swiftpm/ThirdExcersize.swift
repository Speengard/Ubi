
import Foundation
import UIKit
import SwiftUI
import Lottie

protocol ExcersizeDelegate: AnyObject {
    var result: Double { get }
    func handleTermination(_ r: Double)
}

class ThirdExcersizeVC: UIViewController, ExcersizeDelegate {
    
    var currentTest: Binding<Test>
    
    init(_ t: Binding<Test>) {
        self.currentTest = t
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var drawingView: drawingPointsView!
    
    var currentPathPointsL: [CGPoint] = []
    var currentPathPointsR: [CGPoint] = []
    
    weak var timer: Timer?
    var startTime: Double = 0.0
    var time: Double = 0.0
    
    var result: Double = 0.0
    
    var panGesture: UIPanGestureRecognizer!
    
    var overlayView: UIView!
    
    var startDrawButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a view for drawing
        drawingView = drawingPointsView(frame: UIScreen.main.bounds)
        drawingView.backgroundColor = UIColor.clear
        drawingView.delegate = self
        view.addSubview(drawingView)
        
        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.frame = drawingView.bounds
        overlayView.isUserInteractionEnabled = true  // Enable user interaction
        overlayView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        
        self.view.addSubview(overlayView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Excersize with your left hand!"
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
        tooltipLabel.text = "Follow the dotted Path with your left and right fingers. Try to follow it at the same time!"
        
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
        startDrawButton = UIButton(type: .system)
        startDrawButton.setTitle("Start Drawing!", for: .normal)
        startDrawButton.setTitleColor(.white, for: .normal)
        startDrawButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        startDrawButton.sizeToFit()
        
        // Position the button in the bottom right corner
        startDrawButton.frame.origin = CGPoint(x: overlayView.bounds.width - startDrawButton.bounds.width - 40, y: overlayView.bounds.height - startDrawButton.bounds.height - 40)
        
        // Add an action to the button
        startDrawButton.addTarget(self, action: #selector(canStartDraw), for: .touchDown)
        
        overlayView.addSubview(startDrawButton)
        
        // Add a pan gesture recognizer to the drawing view
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 2
        panGesture.isEnabled = false
        
        drawingView.addGestureRecognizer(panGesture)
        
        drawingView.setNeedsDisplay()
    }
    
    @objc func canStartDraw() {
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
        
        
        panGesture.isEnabled = true
        overlayView.removeFromSuperview()
    }

    @objc func advanceTimer(timer: Timer) {
        //Total time since timer started, in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
        self.drawingView.time = time
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @objc func handlePan(_ recognizer : UIPanGestureRecognizer) {
        
        guard let drawingView else {return}
        
        if(recognizer.numberOfTouches < 2) {
            
            currentPathPointsL.removeAll()
            currentPathPointsR.removeAll()
            
            updateDrawing()
            return
        }
        
        let pt1 = recognizer.location(ofTouch: 0, in: self.drawingView)
        let pt2 = recognizer.location(ofTouch: 1, in: self.drawingView)
        
        self.drawingView.checkCorrectContactWithPoint(pt1)
        self.drawingView.checkCorrectContactWithPoint(pt2)
        
        switch recognizer.state {
            case .began:
                print("started gesture")
                currentPathPointsL.removeAll()
                currentPathPointsR.removeAll()
                break
                
            case .changed:
                print("changed gesture")
                currentPathPointsL.append(pt1)
                currentPathPointsR.append(pt2)
                
                updateDrawing()
                break
                
            case .cancelled, .ended:
                print("cancelled gesture")
                
                currentPathPointsL.removeAll()
                currentPathPointsR.removeAll()
                updateDrawing()
                break
                
            default:
                break
        }
        
        return
    }
    
    func updateDrawing() {
        drawingView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let pathL = UIBezierPath()
        pathL.move(to: currentPathPointsL.first ?? .zero)
        
        for point in currentPathPointsL {
            pathL.addLine(to: point)
            pathL.move(to: point)
        }
        
        let pathR = UIBezierPath()
        pathR.move(to: currentPathPointsR.first ?? .zero)
        
        for point in currentPathPointsR {
            pathR.addLine(to: point)
            pathR.move(to: point)
        }
        
        
        let pathShapeLayerL = CAShapeLayer()
        pathShapeLayerL.path = pathL.cgPath
        pathShapeLayerL.strokeColor = UIColor.orange.cgColor
        pathShapeLayerL.lineWidth = 10.0
        
        let pathShapeLayerR = CAShapeLayer()
        pathShapeLayerR.path = pathR.cgPath
        pathShapeLayerR.strokeColor = UIColor.orange.cgColor
        pathShapeLayerR.lineWidth = 10.0
        
        drawingView.layer.addSublayer(pathShapeLayerL)
        drawingView.layer.addSublayer(pathShapeLayerR)
        
        drawingView.setNeedsDisplay()
    }
    
    func handleTermination(_ r: Double) {
        panGesture.isEnabled = false
        
        self.result = r
        self.view.layer.sublayers?.removeAll()
        
        let label = UILabel()
        label.text = "Congratulations! You scored \(Int(result))/100!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
                
        view.addSubview(label)
        NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 250) // Adjust the "50" as needed
                ])
        
        self.currentTest.wrappedValue.hasDoneThirdTest = true
        self.currentTest.wrappedValue.thirdTestResult = r
        self.currentTest.wrappedValue.isComplete = true
        
        let animationView: LottieAnimationView = LottieAnimationView(name: "checkMark")
        
        animationView.frame = view.frame
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.5
        animationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view.addSubview(animationView)
        animationView.play()
        
        view.addSubview(label)
        
    }
}

class drawingPointsView: UIView {
    
    let xCoordinateL = UIScreen.main.bounds.minX + 100
    let xCoordinateR = UIScreen.main.bounds.maxX - 100
    
    let yCoordinate = UIScreen.main.bounds.minY + 80
    
    var desiredPathPointsL: [checkPoint] = []
    var desiredPathPointsR: [checkPoint] = []
    
    var time: Double? = 0.0
    
    var rangeL: Int = 0
    var rangeR: Int = 0
    
    var delegate: ExcersizeDelegate?
    
    var checkL = true {
        didSet { checkFinish() }
    }
    var checkR = true {
        didSet { checkFinish() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tempL = [
            CGPoint(x: xCoordinateL, y: 100 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 140 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 180 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 220 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 260 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 300 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 340 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 380 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 420 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 460 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 500 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 540 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 580 + yCoordinate),
            CGPoint(x: xCoordinateL, y: 620 + yCoordinate),
            
        ]
        
        let tempR = [
            CGPoint(x: xCoordinateR, y: 100 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 140 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 180 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 220 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 260 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 300 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 340 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 380 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 420 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 460 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 500 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 540 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 580 + yCoordinate),
            CGPoint(x: xCoordinateR, y: 620 + yCoordinate),
        ]
        
        desiredPathPointsL = tempL.map( { p in
            return checkPoint(position: p)
        })
        
        desiredPathPointsR = tempR.map( { p in
            return checkPoint(position: p)
        })
        
        desiredPathPointsL = desiredPathPointsL.reversed()
        desiredPathPointsR = desiredPathPointsR.reversed()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Get the current graphics context
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        drawPoints(context)
    }
    
    func drawPoints(_ context: CGContext) {
        print("draw points")
        // Set the point size
        let pointSize: CGFloat = 10.0
        
        // Draw individual points
        for point in self.desiredPathPointsL {
            point.isChecked ? UIColor.green.set() : UIColor.red.set()
            
            context.fillEllipse(in: CGRect(x: point.position.x - pointSize / 2, y: point.position.y - pointSize / 2, width: pointSize, height: pointSize))
        }
        
        for point in self.desiredPathPointsR {
            point.isChecked ? UIColor.green.set() : UIColor.red.set()
            context.fillEllipse(in: CGRect(x: point.position.x - pointSize / 2, y: point.position.y - pointSize / 2, width: pointSize, height: pointSize))
        }
    }
    
    func checkCorrectContactWithPoint(_ p: CGPoint) {
        
        print(desiredPathPointsL[rangeL].position.calculateDistance(point2: p))
        if(desiredPathPointsL[rangeL].position.calculateDistance(point2: p) <= 15 && checkL) {
            print("hit left")
            
            desiredPathPointsL[rangeL].isChecked = true
            desiredPathPointsL[rangeL].checkedTime = time
            
            if(rangeL + 1  == desiredPathPointsL.count) {
                // do something
                checkL = false
            }else {
                rangeL += 1
            }
        }else if(desiredPathPointsR[rangeR].position.calculateDistance(point2: p) <= 15 && checkR) {
            print("hit right")
            
            desiredPathPointsR[rangeR].isChecked = true
            desiredPathPointsR[rangeR].checkedTime = time
            
            if(rangeR + 1  == desiredPathPointsR.count) {
                // do something
                checkR = false
            }else {
                rangeR += 1
            }
        }
    }
    
    func checkFinish() {
        print("check Finish")
        
        if desiredPathPointsL.filter({$0.isChecked != true}).isEmpty && desiredPathPointsR.filter({$0.isChecked != true}).isEmpty {
            
            let timesL = desiredPathPointsL.map({$0.checkedTime!})
            let timesR = desiredPathPointsR.map({$0.checkedTime!})
            
            let zipPairs = zip(timesL, timesR)
            
            var differences: [Double] = []
            
            for pair in zipPairs {
                differences.append(abs(pair.0 - pair.1))
            }
            
            print("differences: " + differences.debugDescription)
            
            var result: Double = 0.0
            
            for d in differences {
                result += d
            }
            
            print("result: " + result.debugDescription)
            
            let nonNegative = max(0,result)
            let scalingFactor: Double = 6
            let formattedResult = 100 - (nonNegative / (nonNegative + scalingFactor)) * (100)
            
            delegate?.handleTermination(formattedResult)
        } else {
            return
        }
    }
    
}


struct ThirdExcersizeHVC: UIViewControllerRepresentable {
    @Binding var test: Test
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return ThirdExcersizeVC($test)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context){
        
    }
    
}

struct checkPoint {
    var isChecked = false
    var position: CGPoint!
    var checkedTime: Double!
}

#Preview(body: {
    ThirdExcersizeHVC(test: .constant(Test()))
})
