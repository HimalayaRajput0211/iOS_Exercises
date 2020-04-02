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
        if UserDefaults.standard.bool(forKey: "cellular_data_status") {
            cellularDataSwitch.setOn(true, animated: false)
        } else {
            cellularDataSwitch.setOn(false, animated: false)
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CellularTableViewController.sectionHeight : 0.0
    }
    
    @IBAction func updateCellularDataStatus(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "cellular_data_status")
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            cell.separatorInset.left = UIScreen.main.bounds.size.width
        }
    }
}


