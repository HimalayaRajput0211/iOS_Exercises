//
//  ConfigurationViewController.swift
//  CollectionViewExercise
//
//  Created by Himalaya Rajput on 26/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class ConfigurationViewController: UIViewController {
    static var maximumDuration: Double = 10.0
    @MaximumValue(maximum: UIScreen.main.bounds.width) private var cellWidth: CGFloat = 50
    @MaximumValue(maximum:  UIScreen.main.bounds.height) private var cellHeight: CGFloat = 50
    @MaximumValue(maximum: UIScreen.main.bounds.width/2) private var cellItemSpacing: CGFloat = 10
    @MaximumDuration private var animationDuration: Double = 0.5
    
    @IBOutlet private weak var itemSpacingTextField: UITextField! {
        didSet {
            itemSpacingTextField.delegate = self
            itemSpacingTextField.returnKeyType = .done
        }
    }
    
    @IBOutlet private weak var heightTextField: UITextField! {
        didSet {
            heightTextField.delegate = self
            heightTextField.returnKeyType = .done
        }
    }
    
    @IBOutlet private weak var widthTextField: UITextField! {
        didSet {
            widthTextField.delegate = self
            widthTextField.returnKeyType = .done
        }
    }
    
    @IBOutlet private weak var animationSpeedTextField: UITextField! {
        didSet {
            animationSpeedTextField.delegate = self
            animationSpeedTextField.returnKeyType = .done
        }
    }
    
    @IBOutlet private weak var animationSpeedStepper: UIStepper!
    @IBOutlet private weak var widthStepper: UIStepper!
    @IBOutlet private weak var heightStepper: UIStepper!
    @IBOutlet private weak var itemSpacingStepper: UIStepper!
    
    @IBAction func navigateToNextVC(_ sender: UIButton) {
        navigate()
    }
    
    @IBAction private func updateAnimationSpeed(_ sender: UIStepper) {
        animationSpeedTextField.text = "\(sender.value)"
        if let animationSpeed = animationSpeedTextField.text , let duration = Double(animationSpeed) {
            animationDuration = duration
        }
    }
    
    @IBAction private func updateWidth(_ sender: UIStepper) {
        widthTextField.text = "\(Int(sender.value))"
        cellWidth = CGFloat(sender.value)
    }
    
    @IBAction private func updateHeight(_ sender: UIStepper) {
        heightTextField.text = "\(Int(sender.value))"
        cellHeight = CGFloat(sender.value)
    }
    
    @IBAction private func updateItemSpacing(_ sender: UIStepper) {
        itemSpacingTextField.text = "\(Int(sender.value))"
        cellItemSpacing = CGFloat(sender.value)
    }
    
    private func navigate() {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: CustomCollectionViewController.identifier) as? CustomCollectionViewController {
            updateData()
            nextVC.cellWidth = cellWidth
            nextVC.animationDuration = animationDuration
            nextVC.cellHeight = cellHeight
            nextVC.cellItemSpacing = cellItemSpacing
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    private func updateData() {
        configureAnimationSpeed(for: CGFloat(animationSpeedTextField.text))
        configureWidth(for: CGFloat(widthTextField.text))
        configureHeight(for: CGFloat(heightTextField.text))
        configureItemSpacing(for: CGFloat(itemSpacingTextField.text))
    }
    
    private func configureAnimationSpeed(for value: CGFloat) {
        animationSpeedStepper.value = Double(value)
        animationDuration = Double(value)
        animationSpeedTextField.text = "\(animationDuration)"
    }
    private func configureWidth(for value: CGFloat) {
        widthStepper.value = Double(value)
        cellWidth = value
        widthTextField.text = "\(cellWidth)"
    }
    private func configureHeight(for value: CGFloat) {
        heightStepper.value = Double(value)
        cellHeight = value
        heightTextField.text = "\(cellHeight)"
    }
    private func configureItemSpacing(for value: CGFloat) {
        itemSpacingStepper.value = Double(value)
        cellItemSpacing = value
        itemSpacingTextField.text = "\(cellItemSpacing)"
    }
}

extension ConfigurationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let editingTextField = EditingTextField(rawValue: textField.tag)
        let value = CGFloat(textField.text)
        switch editingTextField {
        case .animationSpeed: configureAnimationSpeed(for: value)
        case .witdth: configureWidth(for: value)
        case .height: configureHeight(for: value)
        case .itemSpacing: configureItemSpacing(for: value)
        default: break
        }
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
}

extension ConfigurationViewController {
    enum EditingTextField: Int {
        case animationSpeed = 100
        case witdth = 101
        case height = 102
        case itemSpacing = 103
    }
}

