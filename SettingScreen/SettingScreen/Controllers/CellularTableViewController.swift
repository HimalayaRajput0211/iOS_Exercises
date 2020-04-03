//
//  CellularTableViewController.swift
//  SettingScreen
//
//  Created by Himalaya Rajput on 27/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import UIKit

class CellularTableViewController: UITableViewController {
    static private let sectionHeight: CGFloat = 40.0
    @IBOutlet weak var cellularDataSwitch: UISwitch!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableviewStyle()
        if UserDefaults.standard.bool(forKey: PersistenceKeys.cellularDataStatus) {
            cellularDataSwitch.setOn(true, animated: false)
        } else {
            cellularDataSwitch.setOn(false, animated: false)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureTableviewStyle()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CellularTableViewController.sectionHeight : 0.0
    }
    
    @IBAction func updateCellularDataStatus(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: PersistenceKeys.cellularDataStatus)
    }
    
    private func configureTableviewStyle() {
        if UITraitCollection.current.horizontalSizeClass == .regular {
            if !(tableView.style == .insetGrouped) {
                self.tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
            }
        }
    }
}


