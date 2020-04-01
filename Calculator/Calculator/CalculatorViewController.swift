//
//  NewCalculatorViewController.swift
//  Calculator
//
//  Created by Himalaya Rajput on 31/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class CalculatorViewController: UIViewController {
    private var didStartEnteringFirstTime = true
    private var shouldClearDefaultZero = true
    private var enteringSecondNumber = false
    private var firstNumber: String = ""
    private var secondNumber: String = ""
    private var arithmeticOperation: ArithmeticOperation?
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var display: UILabel!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        circleTheButtons()
    }
    
    @IBAction private func numberButtonTapped(_ sender: UIButton) {
        if !didStartEnteringFirstTime {
            display.text = ""
            secondNumber = ""
            didStartEnteringFirstTime = true
        }
        if shouldClearDefaultZero {
            display.text = ""
            shouldClearDefaultZero = false
        }
        if let previousText = display.text, let currentText = sender.currentTitle {
            let newText = previousText + currentText
            if isValidCount(for: newText) {
                display.text = newText
                if enteringSecondNumber {
                    secondNumber = newText
                }
            }
        }
    }
    
    @IBAction private func commandButtonTapped(_ sender: UIButton) {
        if let text = display.text {
            didStartEnteringFirstTime = false
            switch sender.tag {
            case 0:
                if let operation = arithmeticOperation {
                    let exprssion = Expression(expression: firstNumber + " " + operation.rawValue + " " + secondNumber)
                    if let result = exprssion.evaluteExpression() {
                        display.text = result
                        arithmeticOperation = nil
                        enteringSecondNumber = false
                    } else {
                        clearCalculator()
                    }
                }
            case 1:
                arithmeticOperation = .addition
                firstNumber = text
                enteringSecondNumber = true
            case 2:
                arithmeticOperation = .subtraction
                firstNumber = text
                enteringSecondNumber = true
            case 3:
                arithmeticOperation = .multiplication
                firstNumber = text
                enteringSecondNumber = true
            case 4:
                arithmeticOperation = .division
                firstNumber = text
                enteringSecondNumber = true
            case 5:
                clearCalculator()
            default:
                break
            }
        }
    }
    
    private func isValidCount(for text: String) -> Bool {
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
        display.text = "0"
        firstNumber = ""
        secondNumber = ""
        didStartEnteringFirstTime = true
        enteringSecondNumber = false
        shouldClearDefaultZero = true
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        view.alpha = 0.0
        coordinator.animate(alongsideTransition: { _ in }) { _ in
            self.view.alpha = 1.0
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

enum ArithmeticOperation: String {
    case addition = "+"
    case subtraction = "-"
    case multiplication = "*"
    case division = "/"
}
