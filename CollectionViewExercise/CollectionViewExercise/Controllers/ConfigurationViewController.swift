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
    private var activeTextField: UITextField!
    private var screenWidth: CGFloat!
    private var screenHeight: CGFloat!
    private var isPortraitOrientation: Bool!
    private var maximumItemSpacing: CGFloat {
        return isPortraitOrientation ? screenWidth / 2 : screenHeight / 2
    }
    private var maximumWidth: CGFloat {
        return isPortraitOrientation ? screenWidth : screenHeight
    }
    private var maximumHeight: CGFloat {
        return isPortraitOrientation ? screenHeight : screenWidth
    }
    private var cellWidth: CGFloat = 50 {
        didSet {
            cellWidth = min(maximumWidth, cellWidth)
        }
    }
    private var cellHeight: CGFloat = 50 {
        didSet {
            cellHeight = min(maximumHeight, cellHeight)
        }
    }
    private var cellItemSpacing: CGFloat = 10 {
        didSet {
            cellItemSpacing = min(maximumItemSpacing, cellItemSpacing)
        }
    }
    @MaximumDuration private var animationDuration: Double = 0.5
  
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var itemSpacingTextField: UITextField! {
        didSet {
            itemSpacingTextField.delegate = self
            itemSpacingTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet private weak var heightTextField: UITextField! {
        didSet {
            heightTextField.delegate = self
            heightTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet private weak var widthTextField: UITextField! {
        didSet {
            widthTextField.delegate = self
            widthTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet private weak var animationSpeedTextField: UITextField! {
        didSet {
            animationSpeedTextField.delegate = self
            animationSpeedTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet private weak var animationSpeedStepper: UIStepper!
    @IBOutlet private weak var widthStepper: UIStepper!
    @IBOutlet private weak var heightStepper: UIStepper!
    @IBOutlet private weak var itemSpacingStepper: UIStepper!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.all]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScreenSize()
        hideKeybordOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureScreenSize() {
        if UIDevice.current.orientation.isPortrait {
            screenWidth = UIScreen.main.bounds.size.width
            screenHeight = UIScreen.main.bounds.size.height
        } else {
            screenHeight = UIScreen.main.bounds.size.width
            screenWidth = UIScreen.main.bounds.size.height
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            isPortraitOrientation = true
            updateSteppersMaximumValue()
        case .landscapeLeft, .landscapeRight:
            isPortraitOrientation = false
            updateSteppersMaximumValue()
        default: break
        }
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
    
    @IBAction func navigateToNextVC(_ sender: UIButton) {
        navigate()
    }
    
    private func updateSteppersMaximumValue() {
        widthStepper.maximumValue = Double(maximumWidth)
        heightStepper.maximumValue = Double(maximumHeight)
        itemSpacingStepper.maximumValue = Double(maximumItemSpacing)
    }
    
    private func navigate() {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: CustomCollectionViewController.identifier) as? CustomCollectionViewController {
            configureProperties()
            nextVC.cellWidth = cellWidth
            nextVC.animationDuration = animationDuration
            nextVC.cellHeight = cellHeight
            nextVC.cellItemSpacing = cellItemSpacing
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    private func configureProperties() {
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
        widthTextField.text = "\(Int(cellWidth))"
    }
    private func configureHeight(for value: CGFloat) {
        heightStepper.value = Double(value)
        cellHeight = value
        heightTextField.text = "\(Int(cellHeight))"
    }
    private func configureItemSpacing(for value: CGFloat) {
        itemSpacingStepper.value = Double(value)
        cellItemSpacing = value
        itemSpacingTextField.text = "\(Int(cellItemSpacing))"
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        if let infoDict = notification.userInfo {
            if let keyboardFrame = infoDict["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                var aRect: CGRect = self.view.frame
                aRect.size.height -= keyboardFrame.size.height
                if !(aRect.contains(activeTextField.bounds.origin)) {
                    scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
                }
            }
        }
    }
    
    @objc func keyboardWillHide() {
        let contentInsets: UIEdgeInsets = .zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
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
        activeTextField = textField
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

