//
//  SingleSwitchViewController.swift
//  SettingScreen
//
//  Created by Himalaya Rajput on 21/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import UIKit

class SingleSwitchViewController: UITableViewController {
    static private let sectionHeight: CGFloat = 40.0
    var singleSwitchType: Settings.SingleSwitchType!
    weak var delegate: MasterViewControllerUI!
    @IBOutlet private weak var customSwitch: UISwitch!
    @IBOutlet private weak var infoCell: UITableViewCell!
    @IBOutlet private weak var customSwitchTitle: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch singleSwitchType {
        case .bluetooth:
            customSwitchTitle.text = SettingItems.bluetooth.rawValue
            infoCell.isHidden = true
            if UserDefaults.standard.bool(forKey: "bluetooth_status") {
                customSwitch.setOn(true, animated: false)
            } else {
                customSwitch.setOn(false, animated: false)
            }
            title = SettingItems.bluetooth.rawValue
        case .doNotDisturb:
            customSwitchTitle.text = SettingItems.doNotDisturb.rawValue
            infoCell.isHidden = false
            title = SettingItems.doNotDisturb.rawValue
        case .notifications:
            customSwitchTitle.text = SettingItems.notifications.rawValue
            infoCell.isHidden = true
            title = SettingItems.notifications.rawValue
        case .none : break
        }
    }
    
    @IBAction private func updateBluetoothStatus(_ sender: UISwitch) {
        switch singleSwitchType {
        case .bluetooth: UserDefaults.standard.set(sender.isOn, forKey: "bluetooth_status")
        default: break
        }
        delegate.update()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? SingleSwitchViewController.sectionHeight : 0.0
    }
    
}
