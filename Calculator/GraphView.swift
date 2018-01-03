//
//  GraphView.swift
//  Calculator
//
//  Created by Cristian Lucania on 30/12/17.
//  Copyright © 2017 Cristian Lucania. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView
{
    // MARK: - Public API
    
    @IBInspectable
    var origin: CGPoint = CGPoint(x: 0, y: 0) { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }

    @IBInspectable
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    weak var dataSource: UIGraphViewDataSource?
    
    // MARK: - Private Implementation

    private var axes = AxesDrawer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func draw(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()?.saveGState()
        axes.contentScaleFactor = self.contentScaleFactor
        axes.drawAxes(in: rect, origin: origin, pointsPerUnit: scale)
        color.set()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: origin.y))
        var oldY: CGFloat?
        for x in 0...Int(rect.width) {
            if let y = dataSource?.data(forValue: (CGFloat(x)-origin.x)/scale), y.isFinite {
                if let oldY = oldY, abs(oldY - y) < rect.height/scale {
                    path.addLine(to: CGPoint(x: CGFloat(x), y: origin.y-y*scale))
                } else {
                    path.move(to: CGPoint(x: CGFloat(x), y: origin.y-y*scale))
                }
                oldY = y
            } else {
                path.move(to: CGPoint(x: CGFloat(x), y: origin.y))
            }
        }
        path.stroke()
        UIGraphicsGetCurrentContext()?.restoreGState()
    }
    
    private func setup() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(changeScale(byReactingTo:)))
        self.addGestureRecognizer(pinchRecognizer)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveGraph(byReactingTo:)))
        self.addGestureRecognizer(panRecognizer)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(moveOrigin(byReactingTo:)))
        tapRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapRecognizer)
    }

    @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= CGFloat(pinchRecognizer.scale)
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    @objc func moveGraph(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed, .ended:
            let delta = panRecognizer.translation(in: self)
            origin = CGPoint(x: origin.x + delta.x, y: origin.y + delta.y)
            panRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
        default:
            break;
        }
    }
    @objc func moveOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            origin = tapRecognizer.location(in: self)
        }
    }
}

// MARK: - Protocols

protocol UIGraphViewDataSource : class {
    func data(forValue value: CGFloat) -> CGFloat?
}
