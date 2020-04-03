//
//  NewCalculatorViewController.swift
//  Calculator
//
//  Created by Himalaya Rajput on 31/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class CalculatorViewController: UIViewController {
    private var didStartEnteringFirstOperand = true
    private var shouldClearDefaultZero = true
    private var isUsingPreviousResult = false
    private var numericExpression: String = ""
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var calculatorDisplayLabel: UILabel!
    lazy private var maximumLengthOfOperand: Int = {
        if let text = calculatorDisplayLabel.text {
            if Int(text) != nil {
                return 15
            }
            if Double(text) != nil {
                return 20
            }
        }
        return 15
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        circleTheButtons()
    }
   
    @IBAction private func numberButtonTapped(_ sender: UIButton) {
        if isUsingPreviousResult {
            numericExpression = ""
            isUsingPreviousResult = false
        }
        if shouldClearDefaultZero {
            calculatorDisplayLabel.text = ""
            shouldClearDefaultZero = false
        }
        if !didStartEnteringFirstOperand {
            calculatorDisplayLabel.text = ""
            didStartEnteringFirstOperand = true
        }
        if var previousText = calculatorDisplayLabel.text, let currentText = sender.currentTitle {
            if previousText == "inf" {
                previousText = ""
            }
            let newText = previousText + currentText
            if previousText.count < maximumLengthOfOperand {
                appendNumericValueToExpression(currentText)
            }
            if isValidTextToDisplay(for: newText) {
                calculatorDisplayLabel.text = newText
            }
        }
    }
    
    @IBAction private func commandButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if isValidExpressionToEvaluate() {
                configureNumericExpressionForIntegerOperand()
                let expression = NSExpression(format: numericExpression)
                if let result = expression.expressionValue(with: nil, context: nil) as? Double {
                    if let inetgerResult = Int(exactly: result ) {
                        calculatorDisplayLabel.text = "\(inetgerResult)"
                        numericExpression = "\(inetgerResult)"
                        isUsingPreviousResult = true
                    } else {
                        calculatorDisplayLabel.text = "\(result)"
                        if result.isInfinite {
                            numericExpression = ""
                        } else {
                            numericExpression = "\(result)"
                            isUsingPreviousResult = true
                        }
                    }
                }
            }
        case 1:
            if isValidOperand() {
                appendOperator("+")
                isUsingPreviousResult = false
                didStartEnteringFirstOperand = false
            }
        case 2:
            if isValidOperand() {
                appendOperator("-")
                isUsingPreviousResult = false
                didStartEnteringFirstOperand = false
            }
        case 3:
            if isValidOperand() {
                appendOperator("*")
                isUsingPreviousResult = false
                didStartEnteringFirstOperand = false
            }
        case 4:
            if isValidOperand() {
                appendOperator("/")
                isUsingPreviousResult = false
                didStartEnteringFirstOperand = false
            }
        case 5:
            clearCalculator()
        default:
            break
        }
    }
    
    private func appendNumericValueToExpression(_ numericValue: String) {
        if numericValue == "." {
            if let displayText = calculatorDisplayLabel.text ,let _ = displayText.last {
                if isValidTextToDisplay(for: displayText + numericValue) {
                    numericExpression += numericValue
                }
            } else {
                numericExpression += "0."
                calculatorDisplayLabel.text = "0."
            }
        } else {
            numericExpression += numericValue
        }
        
    }
    
    private func appendOperator(_ arithmeticOperator: Character) {
        if let lastCharacter = numericExpression.last {
            if !lastCharacter.isNumber {
                numericExpression.removeLast()
                numericExpression.append(arithmeticOperator)
            } else {
                configureNumericExpressionForIntegerOperand()
                numericExpression.append(arithmeticOperator)
            }
        }
    }
    
    private func isValidExpressionToEvaluate() -> Bool {
        if let lastCharacter = numericExpression.last {
            if lastCharacter.isNumber {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    private func configureNumericExpressionForIntegerOperand() {
        if let operand = calculatorDisplayLabel.text {
            if Int(operand) != nil {
                numericExpression += ".0"
            }
        }
    }
    
    private func isValidOperand() -> Bool {
        if let operand = calculatorDisplayLabel.text {
            if operand.last == "." {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    private func isValidTextToDisplay(for text: String) -> Bool {
        if Int(text) != nil  {
            if text.count <= 15 {
                return true
            } else {
                return false
            }
        }
        if Double(text) != nil {
            if text.count <= 20 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    private func clearCalculator() {
        calculatorDisplayLabel.text = "0"
        numericExpression = ""
        didStartEnteringFirstOperand = true
        isUsingPreviousResult = false
        shouldClearDefaultZero = true
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        view.alpha = 0.0
        coordinator.animate(alongsideTransition: { _ in }) { _ in
            UIView.animate(withDuration: 0.4) {
                self.view.alpha = 1.0
            }
        }
    }
    
    private func circleTheButtons() {
        var buttonCornerRadius: CGFloat?
        for button in buttons {
            buttonCornerRadius = button.frame.size.height / 2
            guard let cornerRadius = buttonCornerRadius else { return }
            button.layer.cornerRadius = cornerRadius
        }
    }
}
