//
//  ViewController.swift
//  Calculator
//
//  Created by Himalaya Rajput on 23/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class CalculatorViewController: UIViewController {
    private var firstOperand = ""
    private var secondOperand = ""
    private var isOperatorSelected: Bool =  false
    private var arithmeticOperation = ""
    private var canPerformCalculationWithPreviousResult: Bool = false
    @IBOutlet private weak var masterStack: UIStackView!
    @IBOutlet private weak var stack1: UIStackView!
    @IBOutlet private weak var stack2: UIStackView!
    @IBOutlet private weak var stack3: UIStackView!
    @IBOutlet private weak var stack4: UIStackView!
    @IBOutlet weak var label: UILabel!
    @IBAction private func updateCalculatorLogic(_ sender: UIButton) {
        switch sender.currentTitle {
        case "": break
        case "+","-","*","/": arithmeticOperatorSelected(on: sender)
        case "AC": resetCalculatorState()
        case "=": calculateResult()
        default: numericButtonSelected(on: sender)
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    private func arithmeticOperatorSelected(on button: UIButton ) {
        if !isOperatorSelected {
            arithmeticOperation = button.currentTitle!
            label.text = nil
            isOperatorSelected = true
        } else {
            resetCalculatorValues()
        }
    }
    
    private func resetCalculatorState() {
        label.text = "0"
        resetCalculatorValues()
    }
    
    private func calculateResult() {
        if isOperatorSelected, secondOperand != "" {
            let exprssion = Expression(expression: firstOperand + " " + arithmeticOperation + " " + secondOperand  )
            do {
                label.text = try exprssion.evaluteExpression()
                isOperatorSelected = false
                secondOperand = ""
                firstOperand = label.text!
                canPerformCalculationWithPreviousResult = true
            } catch {
                label.text = "0"
                print(error.localizedDescription)
            }
        }
    }
    
    private func numericButtonSelected(on button: UIButton) {
        if let number = button.currentTitle {
            if isOperatorSelected {
                secondOperand += number
                label.text = secondOperand
            } else {
                if canPerformCalculationWithPreviousResult { firstOperand = "" }
                firstOperand += number
                label.text = firstOperand
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    private func resetCalculatorValues() {
        firstOperand = ""
        secondOperand = ""
        isOperatorSelected =  false
        arithmeticOperation = ""
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UITraitCollection.current.verticalSizeClass == .compact {
            configureGridforLandscapeOrientation()
        } else {
            configureGridforPortraitOrientation()
        }
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        masterStack.isHidden = true
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print("did transist")
    }
    
    
    private func configureGridforLandscapeOrientation() {
      
        manageVisibility(for: .landscape)
        masterStack.axis = .vertical
        var verticalCount = 0
        stack4.isHidden = true
        let verticalStack = masterStack.arrangedSubviews.filter { !$0.isHidden }
        roundButtons(in: verticalStack)
        verticalStack.forEach { view in
            if let stackView = view as? UIStackView {
                stackView.axis = .horizontal
                stackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton {
                        switch stackView.arrangedSubviews.firstIndex(of: button) {
                        case 0:
                            if verticalCount != 0 {
                                configure(button, for: .landscape, at: 0)
                            }
                        case 1,2,3:
                            verticalCount += 1
                            button.setTitle("\(verticalCount)", for: .normal)
                        case 4: configure(button, for: .landscape, at: 4)
                        default: break
                        }
                    }
                }
            }
        }
        
         // masterStack.isHidden = false
    }
    
    private func configureGridforPortraitOrientation() {
       // masterStack.isHidden = false
        if !stack4.isHidden {stack4.isHidden = true}
        masterStack.axis = .horizontal
        let horizontalStack = masterStack.arrangedSubviews.filter { !$0.isHidden }
        stack4.isHidden = false
        var horizontalCount = 0
        horizontalStack.forEach { view in
            horizontalCount += 1
            if let stackView = view as? UIStackView {
                stackView.axis = .vertical
                stackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton {
                        switch stackView.arrangedSubviews.firstIndex(of: button) {
                        case 0: configure(button, for: .portrait, at: 0)
                        case 1: button.setTitle("\(horizontalCount)", for: .normal)
                        case 2: button.setTitle("\(horizontalCount + 3)", for: .normal)
                        case 3: button.setTitle("\(horizontalCount + 6)", for: .normal)
                        case 4: configure(button, for: .portrait, at: 4)
                        default: break
                        }
                    }
                }
            }
        }
        manageVisibility(for: .portrait)
        roundButtons(in: masterStack.arrangedSubviews.filter { !$0.isHidden } )
        //  masterStack.isHidden = false
    }
    
    private func roundButtons(in views: [UIView]) {
        views.forEach { view in
            if let stackView = view as? UIStackView {
                stackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton {
                        button.layer.cornerRadius = button.frame.size.height / 2
                    }
                }
            }
        }
    }
    
    private func configure(_ button: UIButton, for orientation: Orientation, at index: Int) {
        switch index {
        case 0:
            switch button.tag {
            case 200: button.setTitle(orientation.isPortrait ? "" : ".", for: .normal)
            case 201: button.setTitle(orientation.isPortrait ? "" : "0", for: .normal)
            default: break
            }
            button.backgroundColor = orientation.isPortrait ? .white : .darkGray
            button.titleLabel?.textColor = orientation.isPortrait ? .black : .white
        case 4:
            switch button.tag {
            case 100: button.setTitle(orientation.isPortrait ? "." : "=", for: .normal)
            case 101: button.setTitle(orientation.isPortrait ? "0" : "", for: .normal)
            case 102: button.setTitle(orientation.isPortrait ? "" : "/", for: .normal)
            default: break
            }
            button.backgroundColor = orientation.isPortrait ? .darkGray : .systemOrange
            button.titleLabel?.textColor = .white
        default: break
        }
    }
    
    private func manageVisibility(for orientation: Orientation) {
        stack1.arrangedSubviews.last?.isHidden = orientation.isPortrait ? true : false
        stack2.arrangedSubviews.last?.isHidden = orientation.isPortrait ? true : false
        stack3.arrangedSubviews.last?.isHidden = orientation.isPortrait ? true : false
        stack4.arrangedSubviews.last?.isHidden = orientation.isPortrait ? true : false
    }
}

extension CalculatorViewController{
    enum Orientation {
        case landscape
        case portrait
        var isPortrait: Bool {
            switch self {
            case .landscape: return false
            case .portrait: return true
            }
        }
    }
}


