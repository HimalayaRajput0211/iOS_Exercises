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
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CellularTableViewController.sectionHeight : 0.0
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            cell.separatorInset.left = UIScreen.main.bounds.size.width
        }
    }
}


