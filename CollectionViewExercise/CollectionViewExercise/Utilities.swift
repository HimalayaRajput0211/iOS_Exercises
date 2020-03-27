//
//  Utilities.swift
//  CollectionViewExercise
//
//  Created by Himalaya Rajput on 19/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    /*
     this initializer converts String to CGFloat 
    */
    init(_ value: String?) {
        self.init()
        if let newValue = value, let doubleValue = Double(newValue) {
            self = CGFloat(doubleValue)
        } else {
          self = 0
        }
    }
}

extension IndexPath {
     init(row: Int) {
        self.init(row: row, section: 0)
    }
}

@propertyWrapper
struct MaximumDuration {
    var maximum: Double
    var duration: Double
    var wrappedValue: Double {
        get {
            return duration
        } set {
            duration = min(maximum, newValue)
        }
    }
    init(wrappedValue: Double) {
        maximum = ConfigurationViewController.maximumDuration
        duration = min(wrappedValue, maximum)
    }
}

extension UIViewController {
    
    func hideKeybordOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
