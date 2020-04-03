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
    static private let footerTitle: String = "When Do Not Disturb is enabled, calls and alerts that arrive whle locked will be silenced, and a moon icon will appear in the status bar."
    static private let sectionHeight: CGFloat = 40.0
    var singleSwitchType: Settings.SingleSwitchType!
    weak var delegate: MasterViewControllerUI!
    @IBOutlet private weak var customSwitch: UISwitch!
    @IBOutlet private weak var customSwitchTitle: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableviewStyle()
        switch singleSwitchType {
        case .bluetooth:
            customSwitchTitle.text = SettingItems.bluetooth.rawValue
            if UserDefaults.standard.bool(forKey: PersistenceKeys.bluetoothStatus) {
                customSwitch.setOn(true, animated: false)
            } else {
                customSwitch.setOn(false, animated: false)
            }
            title = SettingItems.bluetooth.rawValue
        case .doNotDisturb:
            customSwitchTitle.text = SettingItems.doNotDisturb.rawValue
            title = SettingItems.doNotDisturb.rawValue
        case .notifications:
            customSwitchTitle.text = SettingItems.notifications.rawValue
            title = SettingItems.notifications.rawValue
        case .none : break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureTableviewStyle()
    }
    @IBAction private func updateBluetoothStatus(_ sender: UISwitch) {
        switch singleSwitchType {
        case .bluetooth: UserDefaults.standard.set(sender.isOn, forKey: PersistenceKeys.bluetoothStatus)
        default: break
        }
        delegate.update()
    }
    
    private func configureTableviewStyle() {
        if UITraitCollection.current.horizontalSizeClass == .regular {
            if !(tableView.style == .insetGrouped) {
                self.tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SingleSwitchViewController.sectionHeight
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch singleSwitchType {
        case .bluetooth, .notifications: return nil
        default: break
        }
        return SingleSwitchViewController.footerTitle
    }
    
}
