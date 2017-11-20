//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Gus Uy on 5/7/17.
//  Copyright © 2017 Gus Uy. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    private var accumulator: (Double, String)?
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }

    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "±" : Operation.unaryOperation({ -$0 }),
        "%" : Operation.unaryOperation({ $0 / 100 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "=" : Operation.equals
    ]
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var result: Double? {
        get {
            return accumulator?.0 ?? nil
        }
    }
    
    var description: String? {
        get {
            if resultIsPending {
                return "\(pendingBinaryOperation!.firstOperand.1) \(pendingBinaryOperation!.function.1) \(accumulator?.1 ?? "")"
            }
            else {
                return accumulator?.1 ?? nil
            }
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (((Double, Double) -> Double), String)
        let firstOperand: (Double, String)
        
        func performBinaryOperation(with secondOperand: (Double, String)) -> (Double, String) {
            return (function.0(firstOperand.0, secondOperand.0), "\(firstOperand.1) \(function.1) \(secondOperand.1)")
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol)
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = (function(accumulator!.0), "\(symbol)(\(accumulator!.1))")
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending {
                        performPendingBinaryOperation()
                    }
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: (function, symbol), firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.performBinaryOperation(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, "\(operand)")
    }
    
}
