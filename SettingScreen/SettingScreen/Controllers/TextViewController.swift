//
//  ViewController.swift
//  SettingScreen
//
//  Created by Himalaya Rajput on 19/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class TextViewController: UIViewController {
    var textType = Settings.TextType.general    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch textType {
        case .general: title = SettingItems.general.rawValue
        case .wallpaper: title = SettingItems.wallpaper.rawValue
        }
    }
}

