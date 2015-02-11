//
//  CalculatorBrain.swift
//  StanfordCalcDemo
//
//  Created by Christopher Wood on 2/10/15.
//  Copyright (c) 2015 Christopher Wood. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    var description: String? {
        get {
            let (display, _) = describe(opStack)
            return display
        }
    }
    
    // Return value you are looking for and returning ops each iteration.
    private func describe(ops: [Op]) -> (display: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(_):
                var display = op.description
                return (display, remainingOps)
            case .Constant(_, _):
                let display = op.description
                return (display, remainingOps)
            case .UnaryOperation(_ , _):
                if remainingOps.count > 0 {
                    let op1Description = describe(remainingOps)
                    if let op1Display = op1Description.display {
                        let display = op.description + "(" + op1Display + ")"
                        return (display, op1Description.remainingOps)
                    } else{ return (nil, [])}
                } else { return (nil, [])}
            case .BinaryOperation(_, _):
                let op1Description = describe(remainingOps)
                if let op1Display = op1Description.display {
                    let op2Description = describe(op1Description.remainingOps)
                    if let op2Display = op2Description.display {
                        let display = op2Display + op.description + op1Display
                        return (display, op2Description.remainingOps)
                    } else {
                        let display = "?" + op.description + op1Display
                        return (display, [])
                    }
                } else { return (nil, [])}
            }
        } else {
            return (nil, [])
        }
    }
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String : Op]()
    
    var variableValues = [String: Double]()
    
    // TODO: Add Pi
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("-") { $1 - $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let operand):
                return (operand, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        if let value = variableValues[symbol] {
            opStack.append(Op.Constant(symbol, value))
            return evaluate()
        }else {
            return nil
        }
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
            return evaluate()
        } else {
            return nil
        }
    }
    
    func clear() {
        opStack.removeAll(keepCapacity: false)
        variableValues.removeAll(keepCapacity: false)
    }
}