//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Cristian Lucania on 21/02/17.
//  Copyright © 2017 Cristian Lucania. All rights reserved.
//

import Foundation

struct CalculatorBrain : CustomStringConvertible
{
    // MARK: - Public API

    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    var description: String {
        return evaluate().description
    }
    
    var result: Double? {
        return evaluate().result
    }
    
    mutating func clear() {
        expression = []
    }

    mutating func setOperand(_ operand: Double) {
        expression.append(Element.operand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        expression.append(Element.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
        expression.append(Element.operation(symbol))
    }
    
    mutating func undo() {
        if expression.count > 0 {
            expression.removeLast()
        }
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var accumulator: (value: Double, description: String)?
        var pendingBinaryOperation: PendingBinaryOperation?
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
        struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            let firstOperand: (Double, String)
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }

        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        for element in expression {
            switch element {
            case .operand(let operand):
                accumulator = (operand, "\(operand.toString()!)")

            case .variable(let variable):
                let operand = variables?[variable] ?? 0
                accumulator = (operand, variable)

            case .operation(let symbol):
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
        
        return (result, resultIsPending, description ?? " ")
    }
    
    // MARK: - Private Implementation
    
    private var expression = [Element]()
    
    private enum Element {
        case variable(String)
        case operand(Double)
        case operation(String)
    }
    
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
}
