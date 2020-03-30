//
//  SelectNetworkViewController.swift
//  SettingScreen
//
//  Created by Himalaya Rajput on 21/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//
import UIKit

protocol MasterViewControllerUI: AnyObject {
    func update()
}

class SelectNetworkViewController: UIViewController {
    var networkType = Settings.NetworkType.network
    weak var delegate: MasterViewControllerUI!
    @IBOutlet private var networks: [UIButton]! {
        didSet {
            for i in 0..<networks.count {
                networks[i].setTitle(networkType.rawValue + "\(i + 1)", for: .normal)
            }
        }
    }
    
    @IBAction private func updateNetworkName(_ sender: UIButton) {
        switch networkType {
        case .network : UserDefaults.standard.set(sender.currentTitle, forKey: "wifi_network_name")
        case .carrier : UserDefaults.standard.set(sender.currentTitle, forKey: "carrier_network_name")
        }
        delegate.update()
    }
}
