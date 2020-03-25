//
//  Expression.swift
//  Calculator
//
//  Created by Himalaya Rajput on 25/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
enum GeneralError: LocalizedError {
    case invalidExpressionFormat
    case zeroUncertainity
    case invalidOperator
    var errorDescription: String? {
        switch self {
        case .invalidExpressionFormat:
            return "there should be a space between operator and operands"
        case .zeroUncertainity:
            return "the denomenator can't be a zero"
        case .invalidOperator:
            return "the allowed arithmetic operations are (+, -, *, / )."
        }
    }
}

enum DoubleParsingError: LocalizedError {
    case overflow
    var errorDescription: String? {
        switch self {
        case .overflow:
            return "Overflow error"
        }
    }
}

extension Double {
    init(convertToDouble input: String) throws {
        guard let newDouble = Double(input) else {
            throw DoubleParsingError.overflow
        }
        self = newDouble
    }
    
    func roundToPlace(_ value: Int) -> String {
        return String(format: "%.\(String(value))f", self)
    }
}

class Expression {
    private var expression: String
    init(expression: String) {
        self.expression = expression
    }
    
    private func calculate(_ evaluate:((Double, Double) -> Double), a: Double, b: Double, precision: Int) throws -> String {
        let result: Double? = evaluate(a, b)
        guard (result != nil) else {
            throw DoubleParsingError.overflow
        }
        return result!.roundToPlace(precision)
    }
    
    private func getPrecision(_ s: String) -> Int {
        let index = s.firstIndex(of: ".")
        guard index != nil else {
            return 0
        }
        let str = s[s.index(after: index!)..<s.endIndex]
        return str.count
    }
    
    func evaluteExpression() throws -> String {
        let expressionValues = expression.components(separatedBy: " ")
        guard expressionValues.count == 3 else {
            throw GeneralError.invalidExpressionFormat
        }
        let a = try Double(convertToDouble: expressionValues[0])
        let b = try Double(convertToDouble: expressionValues[2])
        let precisionOfA = min(15, getPrecision(expressionValues[0]))
        let precisionOfB = min(15, getPrecision(expressionValues[2]))
        
        switch expressionValues[1] {
        case "+":
            return try calculate(+, a: a, b: b, precision: min(15, max(precisionOfA, precisionOfB)))
        case "-":
            return try calculate(-, a: a, b: b, precision: min(15, max(precisionOfA, precisionOfB)))
        case "*":
            if a == 0.0 || b == 0.0 {
                return try calculate(*, a: a, b: b, precision: 0)
            } else {
                return try calculate(*, a: a, b: b, precision: min(15, precisionOfA + precisionOfB))
            }
        case "/":
            guard b != 0 else {
                throw GeneralError.zeroUncertainity
            }
            if a == 0.0 {
                return try calculate(/, a: a, b: b, precision: 0)
            } else {
                return try calculate(/, a: a, b: b, precision: min(15, max(precisionOfA, precisionOfB)))
            }
        default:
            throw GeneralError.invalidOperator
        }
    }
}

