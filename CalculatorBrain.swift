//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Matthew Green on 8/31/17.
//  Copyright © 2017 Matthew Green. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    private var accumulatorDeprecate: Double?
    
    var resultIsPending: Bool? {
        return evaluate().isPending
    }
    
    var description: String? {
        return evaluate().description
    }
    
    private var elementQueue = [Element]()
    
    private enum Element {
        case operation(String)
        case operand(Double)
        case variable(String)
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "tan" : Operation.unaryOperation(tan),
        "%" : Operation.unaryOperation({$0 / 100}),
        "±" : Operation.unaryOperation({ -$0 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "=" : Operation.equals
    ]
    
    mutating func setOperand(variable named: String) {
        elementQueue.append(Element.variable(named))
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var accumulator: Double?
        var isPending: Bool = false
        var description: String = String()
        var didEquate: Bool?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        for element in elementQueue {
            switch element {
            case .operand(let value):
                if isPending {
                    description += String(value)
                } else {
                    description = String(value)
                }
                accumulator = value
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        didEquate = false
                        if isPending {
                            description += String(symbol)
                        } else {
                            description = symbol
                        }
                        accumulator = value
                    case .unaryOperation(let function):
                        if accumulator != nil {
                            if didEquate ?? false {
                                description = symbol + "(" + description +  ")"
                            } else {
                                let operand = String(accumulator!)
                                let newDescription = description.dropLast(operand.count)
                                description = String(describing: newDescription) + symbol + "(" + operand + ")"
                            }
                            didEquate = false
                            accumulator = function(accumulator!)
                        }
                    case .binaryOperation(let function):
                        if accumulator != nil {
                            didEquate = false
                            performPendingBinaryOperation()
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                            description += symbol
                            isPending = true
                        }
                    case .equals:
                        performPendingBinaryOperation()
                        didEquate = true
                        isPending = false
                    }
                }
            case .variable(let symbol):
                var value: Double = 0
                if variables?[symbol] != nil {
                    value = (variables?[symbol])!
                }
                if isPending {
                    description += symbol
                } else {
                    description = symbol
                }
                accumulator = value
            }
        }
        return (accumulator, isPending, description)
    }
    
    mutating func performOperation(_ symbol: String) {
        elementQueue.append(Element.operation(symbol))
//        if let operation = operations[symbol] {
//            switch operation {
//            case .constant(let value):
//                didEquate = false
//                if resultIsPending ?? false {
//                    description! += symbol
//                } else {
//                    description = symbol
//                }
//                accumulator = value
//            case .unaryOperation(let function):
//                if accumulator != nil {
//                    if didEquate ?? false {
//                        description = symbol + "(" + description! +  ")"
//                    } else {
//                        let operand = String(accumulator!)
//                        let newDescription = description!.dropLast(operand.count)
//                        description! = String(describing: newDescription) + symbol + "(" + operand + ")"
//                    }
//                    didEquate = false
//                    accumulator = function(accumulator!)
//                }
//            case .binaryOperation(let function):
//                if accumulator != nil {
//                    didEquate = false
//                    performPendingBinaryOperation()
//                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
//                    description! += symbol
//                    resultIsPending = true
//                }
//            case .equals:
//                performPendingBinaryOperation()
//                didEquate = true
//                resultIsPending = false
//            }
//        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand);
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        elementQueue.append(Element.operand(operand))
//        if resultIsPending ?? false {
//            description! += String(operand)
//        } else {
//            description = String(operand)
//        }
//        accumulator = operand
    }
    
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
}
