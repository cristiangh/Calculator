//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Cristian on 21/02/17.
//  Copyright © 2017 Cristian. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private var accumulator: (value: Double, description: String)?
    
    private var pendingBinaryOperation: PendingBinaryOperation?
   
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
  
    private var operations: Dictionary<String, Operation> = [
        "π"   : Operation.constant        (Double.pi),
        "e"   : Operation.constant        (M_E),
        "cos" : Operation.unaryOperation  (cos, {"cos(\($0))"}),
        "sin" : Operation.unaryOperation  (sin, {"sin(\($0))"}),
        "√"   : Operation.unaryOperation  (sqrt, {"√(\($0))"}),
        "x²"  : Operation.unaryOperation  ({ $0 * $0 }, {"(\($0))²"}),
        "x⁻¹" : Operation.unaryOperation  ({ 1 / $0 }, {"\($0)⁻¹"}),
        "±"   : Operation.unaryOperation  ({ -$0 }, {"-\($0)"}),
        "×"   : Operation.binaryOperation ({ $0 * $1 }, {"\($0)x\($1)"}),
        "÷"   : Operation.binaryOperation ({ $0 / $1 }, {"\($0)÷\($1)"}),
        "+"   : Operation.binaryOperation ({ $0 + $1 }, {"\($0)+\($1)"}),
        "-"   : Operation.binaryOperation ({ $0 - $1 }, {"\($0)-\($1)"}),
        "="   : Operation.equals
    ]

    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let description: (String, String) -> String
        let firstOperand: (Double, String)
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
    }

    mutating private func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
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
    
    var description: String? {
        if resultIsPending {
            return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.description ?? "")
        } else {
            return accumulator?.description
        }
    }
    
    var result: Double? {
        return accumulator?.value
    }
    
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
    }

    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, string(from: operand))
    }

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol)
            case .unaryOperation(let function, let description):
                if accumulator != nil {
                    accumulator = (function(accumulator!.value), description(accumulator!.description))
                }
            case .binaryOperation(let function, let description):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
}
