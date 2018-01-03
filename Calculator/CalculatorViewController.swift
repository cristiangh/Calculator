//
//  ViewController.swift
//  Calculator
//
//  Created by Cristian on 12/02/17.
//  Copyright © 2017 Cristian. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate
{
    // MARK: - Public API
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var variable: UILabel!
    
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
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        let evaluation = brain.evaluate(using: variables)
        updateUI(with: evaluation)
    }
    
    @IBAction func performEvaluate() {
        variables["M"] = displayValue
        userIsInTheMiddleOfTyping = false
        let evaluation = brain.evaluate(using: variables)
        updateUI(with: evaluation)
    }
    
    @IBAction func setM() {
        brain.setOperand(variable: "M")
        let evaluation = brain.evaluate(using: variables)
        updateUI(with: evaluation)
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTyping = false
        variables = [:]
        brain.clear()
        variable.text = " "
        history.text = " "
        display.text = "0"
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTyping, var text = display.text {
            text.removeLast()
            if text.isEmpty {
                text = "0"
                userIsInTheMiddleOfTyping = false
            }
            display.text = text
        } else {
            brain.undo()
            let evaluation = brain.evaluate(using: variables)
            updateUI(with: evaluation)
        }
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return (identifier == "showGraph" && !brain.resultIsPending)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGraph" {
            if let graphVC = segue.destination.contents as? GraphViewController {
                graphVC.title = brain.evaluate().description
                graphVC.function = {
                    (x: Double) -> Double? in
                    return self.brain.evaluate(using: ["M": x]).result
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }
    
    // MARK: - Private Implementation
    
    private var brain = CalculatorBrain()
    
    private var variables = [String: Double]() {
        didSet {
            variable.text = variables.flatMap{$0 + " = " + $1.toString()!}.joined(separator: ", ")
        }
    }
    
    private var userIsInTheMiddleOfTyping = false
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = newValue.toString()
        }
    }
    
    private func updateUI(with evaluation: (result: Double?, isPending: Bool, description: String)) {
        if let result = evaluation.result {
            displayValue = result
        }
        history.text = "\(evaluation.description)\(evaluation.isPending ? "..." : "=")"
    }

    // MARK: - Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contents == self {
            return true
        }
        return false
    }
}

// MARK: - Extensions

extension Double {
    func toString() -> String? {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 6
        return nf.string(from: NSNumber(value: self))
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
