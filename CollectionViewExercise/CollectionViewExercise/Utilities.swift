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
    init(_ value: String?) {
        self.init()
        if let newValue = value, let doubleValue = Double(newValue) {
            if doubleValue < 0 {
                self = -CGFloat(doubleValue)
            } else {
                self = CGFloat(doubleValue)
            }
        }
    }
}

extension IndexPath {
     init(row: Int) {
        self.init(row: row, section: 0)
    }
}

@propertyWrapper
struct MaximumValue {
    var maximum: CGFloat
    var value: CGFloat
    var wrappedValue: CGFloat {
        get {
            return value
        } set {
            value = min(maximum, newValue)
        }
    }
    init(wrappedValue: CGFloat, maximum: CGFloat ) {
        self.maximum = maximum
        value = min(maximum, wrappedValue)
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
