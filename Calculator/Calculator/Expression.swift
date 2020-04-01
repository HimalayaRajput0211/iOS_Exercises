//
//  Expression.swift
//  Calculator
//
//  Created by Himalaya Rajput on 25/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//
import Foundation
class Expression {
    private var expression: String
    init(expression: String) {
        self.expression = expression
    }
    
    private func calculate(_ evaluate:((Double, Double) -> Double), a: Double, b: Double, precision: Int) -> String {
        return evaluate(a, b).roundToPlace(precision)
    }
    
    private func getPrecision(_ s: String) -> Int {
        let index = s.firstIndex(of: ".")
        guard index != nil else {
            return 0
        }
        let str = s[s.index(after: index!)..<s.endIndex]
        return str.count
    }
    
    func evaluteExpression() -> String? {
        let expressionValues = expression.components(separatedBy: " ")
        guard expressionValues.count == 3 else {
           return nil
        }
        guard let a = Double(expressionValues[0]) else {return nil}
        guard let b = Double(expressionValues[2]) else {return nil}
        let precisionOfA = min(15, getPrecision(expressionValues[0]))
        let precisionOfB = min(15, getPrecision(expressionValues[2]))
        
        switch expressionValues[1] {
        case "+":
            return calculate(+, a: a, b: b, precision: min(15, max(precisionOfA, precisionOfB)))
        case "-":
            return calculate(-, a: a, b: b, precision: min(15, max(precisionOfA, precisionOfB)))
        case "*":
            if a == 0.0 || b == 0.0 {
                return calculate(*, a: a, b: b, precision: 0)
            } else {
                return calculate(*, a: a, b: b, precision: min(15, precisionOfA + precisionOfB))
            }
        case "/":
            guard b != 0 else {
                return nil
            }
            if a == 0.0 {
                return calculate(/, a: a, b: b, precision: 0)
            } else {
                return calculate(/, a: a, b: b, precision: min(15, max(precisionOfA, precisionOfB)))
            }
        default: return nil
        }
    }
}

extension Double {
    func roundToPlace(_ value: Int) -> String {
        return String(format: "%.\(String(value))f", self)
    }
}
