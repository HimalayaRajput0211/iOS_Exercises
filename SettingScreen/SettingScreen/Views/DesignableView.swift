//
//  DesignableView.swift
//  SettingScreen
//
//  Created by Himalaya Rajput on 19/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DesignableView: UIView {
    @IBInspectable
    private var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}

