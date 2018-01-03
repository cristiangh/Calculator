//
//  GraphViewController.swift
//  Calculator
//
//  Created by Cristian Lucania on 30/12/17.
//  Copyright © 2017 Cristian Lucania. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, UIGraphViewDataSource
{
    // MARK: - Public API
    
    var function: ((Double) -> Double?)! // Model

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
        }
    }

    func data(forValue value: CGFloat) -> CGFloat? {
        if let result = function(Double(value)) {
            return CGFloat(result)
        } else {
            return nil
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        graphView.origin = CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
    }
}
