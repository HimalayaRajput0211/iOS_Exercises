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
    
    
    override init(style: UITableView.Style) {
           switch SceneDelegate.deviceType {
           case .iphone: super.init(style: .grouped)
           case .ipad: super.init(style: .insetGrouped)
           }
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
       }
       
    private let sectionHeight: CGFloat = 40.0
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? sectionHeight : 0.0
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            cell.separatorInset.left = UIScreen.main.bounds.size.width
        }
    }
}

class CustomTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        var customStyle: UITableView.Style!
        switch SceneDelegate.deviceType {
        case .iphone: super.init(style: .grouped)
        case .ipad: super.init(style: .insetGrouped)
        }
        
        super.init(frame: frame, style: .)
    }
}