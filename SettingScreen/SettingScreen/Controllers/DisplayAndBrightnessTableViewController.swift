//
//  DisplayAndBrightnessViewController.swift
//  SettingScreen
//
//  Created by Himalaya Rajput on 03/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import UIKit
class DisplayAndBrightnessTableViewController: UITableViewController {
    static private let lastSection: Int = 4
    static private let sectionHeight: CGFloat = 40.0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableviewStyle()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureTableviewStyle()
    }
    private func configureTableviewStyle() {
        if UITraitCollection.current.horizontalSizeClass == .regular {
            if !(tableView.style == .insetGrouped) {
                self.tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return DisplayAndBrightnessTableViewController.sectionHeight
     }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == DisplayAndBrightnessTableViewController.lastSection {
            return UITableView.automaticDimension
        } else {
            return 0.0
        }
    }
 
}
