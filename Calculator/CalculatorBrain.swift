//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Cristian on 21/02/17.
//  Copyright © 2017 Cristian. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private var accumulator: (value: Double?, description: String?)
    private var pendingBinaryOperation: PendingBinaryOperation?

    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOpertion((Double, Double) -> Double)
        case equals
    }
  
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "x²" : Operation.unaryOperation() { $0 * $0 },
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "±" : Operation.unaryOperation() { -$0 },
        "%" : Operation.unaryOperation() { $0 / 100 },
        "×" : Operation.binaryOpertion { $0 * $1 },
        "÷" : Operation.binaryOpertion() { $0 / $1 },
        "+" : Operation.binaryOpertion() { $0 + $1 },
        "-" : Operation.binaryOpertion() { $0 - $1 },
        "=" : Operation.equals
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
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    var result: Double? {
        return accumulator.value
    }
    
    var description: String? {
        return accumulator.description
    }
    
    mutating func clear() {
        accumulator.value = nil
        accumulator.description = nil
        pendingBinaryOperation = nil
    }

    mutating func setOperand(_ operand: Double) {
        accumulator.value = operand
    }

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator.value = value
            case .unaryOperation(let function):
                if accumulator.value != nil {
                    accumulator.value = function(accumulator.value!)
                }
            case .binaryOpertion(let function):
                if accumulator.value != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.value!)
                    accumulator.value = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
            
        }
    }
}