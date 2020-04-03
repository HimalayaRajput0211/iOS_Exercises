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
    private var currentEditingView: EditingFieldType?
    private var screenWidth: CGFloat {
        if UIDevice.current.orientation.isPortrait {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    private var screenHeight: CGFloat {
        if UIDevice.current.orientation.isPortrait {
            return UIScreen.main.bounds.size.height
        } else {
            return UIScreen.main.bounds.size.width
        }
    }
    private var isPortraitOrientation: Bool = true
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
            animationSpeedTextField.keyboardType = .default
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
        hideKeybordOnTap()
        setkeyBoardObservers()
        
    }
    private func setkeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
                var activeView: UITextField? {
                    switch currentEditingView {
                    case .animationSpeedTextField: return animationSpeedTextField
                    case .widthTextField : return widthTextField
                    case .heightTextField: return heightTextField
                    case .itemSpacingTextField: return itemSpacingTextField
                    default: return nil
                    }
                }
                if let activeView = activeView {
                    if !(aRect.contains(activeView.bounds.origin)) {
                        scrollView.scrollRectToVisible(activeView.frame, animated: true)
                    }
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
        let value = CGFloat(textField.text)
        switch currentEditingView {
        case .animationSpeedTextField: configureAnimationSpeed(for: value)
        case .widthTextField: configureWidth(for: value)
        case .heightTextField: configureHeight(for: value)
        case .itemSpacingTextField: configureItemSpacing(for: value)
        default: break
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = .none
        currentEditingView = EditingFieldType(rawValue: textField.tag)
    }
}

extension ConfigurationViewController {
    enum EditingFieldType: Int {
        case animationSpeedTextField = 100
        case widthTextField = 101
        case heightTextField = 102
        case itemSpacingTextField = 103
    }
}


