//
//  ViewController.swift
//  Calculator
//
//  Created by Cristian on 12/02/17.
//  Copyright © 2017 Cristian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var variable: UILabel!
    
    private var brain = CalculatorBrain()

    var userIsInTheMiddleOfTyping = false

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || !textCurrentlyInDisplay.contains(".") {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = (digit == ".") ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            let nf = NumberFormatter()
            nf.minimumFractionDigits = 0
            nf.maximumFractionDigits = 6
            display.text = nf.string(from: NSNumber(value: newValue))
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if let description = brain.description {
            history.text = "\(description)\(brain.resultIsPending ? "..." : "=")"
        } else {
            history.text = " "
        }
    }

    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        history.text = " "
        userIsInTheMiddleOfTyping = false
    }
}

