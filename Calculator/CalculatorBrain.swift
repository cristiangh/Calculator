//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Cristian on 21/02/17.
//  Copyright © 2017 Cristian. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private var accumulator: (value: Double?, description: String)
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var lastOperationIsBinary: Bool = false

    init() {
        accumulator = (nil, "")
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
  
    private var operations: Dictionary<String, Operation> = [
        "π"   : Operation.constant        (Double.pi),
        "e"   : Operation.constant        (M_E),
        "cos" : Operation.unaryOperation  (cos),
        "sin" : Operation.unaryOperation  (sin),
        "√"   : Operation.unaryOperation  (sqrt),
        "x²"  : Operation.unaryOperation  { $0 * $0 },
        "±"   : Operation.unaryOperation  { -$0 },
        "1/x"   : Operation.unaryOperation  { 1 / $0 },
        "×"   : Operation.binaryOperation { $0 * $1 },
        "÷"   : Operation.binaryOperation { $0 / $1 },
        "+"   : Operation.binaryOperation { $0 + $1 },
        "-"   : Operation.binaryOperation { $0 - $1 },
        "="   : Operation.equals
    ]

    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }

    mutating private func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            accumulator.value = pendingBinaryOperation!.perform(with: accumulator.value!)
            pendingBinaryOperation = nil
        }
    }
    
    private func string(from value: Double) -> String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 6
        return nf.string(from: NSNumber(value: value))!
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    var description: String {
        return accumulator.description
    }
    
    var result: Double? {
        return accumulator.value
    }
    
    mutating func clear() {
        accumulator = (nil, "")
        pendingBinaryOperation = nil
    }

    mutating func setOperand(_ operand: Double) {
        accumulator.value = operand
        if !resultIsPending {
            accumulator.description = "\(string(from: operand))"
        }
    }

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator.value = value
                if resultIsPending {
                    accumulator.description += "\(symbol)"
                } else {
                    accumulator.description = "\(symbol)"
                }
                lastOperationIsBinary = false
            case .unaryOperation(let function):
                if accumulator.value != nil {
                    if resultIsPending {
                        if symbol == "1/x" {
                            accumulator.description += "1/(\(string(from: accumulator.value!)))"
                        } else if symbol == "x²" {
                            accumulator.description += "(\(string(from: accumulator.value!)))²"
                        } else {
                            accumulator.description += "\(symbol)(\(string(from: accumulator.value!)))"
                        }
                    } else {
                        if symbol == "1/x" {
                            accumulator.description = "1/(\(accumulator.description))"
                        } else if symbol == "x²" {
                            accumulator.description = "(\(accumulator.description))²"
                        } else {
                            accumulator.description = "\(symbol)(\(accumulator.description))"
                        }
                    }
                    accumulator.value = function(accumulator.value!)
                }
                lastOperationIsBinary = false
            case .binaryOperation(let function):
                if accumulator.value != nil {
                    if resultIsPending {
                        accumulator.description += "\(string(from:accumulator.value!))"
                        performPendingBinaryOperation()
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.value!)
                    accumulator.description += "\(symbol)"
                }
                lastOperationIsBinary = true
            case .equals:
                if resultIsPending && lastOperationIsBinary {
                    accumulator.description += "\(string(from:accumulator.value!))"
                }
                performPendingBinaryOperation()
            }
            
        }
    }
}
