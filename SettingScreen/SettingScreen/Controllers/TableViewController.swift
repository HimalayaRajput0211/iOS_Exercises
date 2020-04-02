//
//  TableViewController.swift
//  SettingScreen
//
//  Created by Himalaya Rajput on 19/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import UIKit

class TableViewcontroller: UITableViewController, MasterViewControllerUI {
    
    private let rowHeight: CGFloat = 55.0
    private let sectionHeight: CGFloat = 40.0
    private var networkType: Settings.NetworkType!
    private var singleSwitchType: Settings.SingleSwitchType!
    private var textType: Settings.TextType!
    private var searchArray: [SearchData] = [
        SearchData(name: SettingItems.airplaneMode.rawValue, indexpath: IndexPath(row: 0, section: 0)),
        SearchData(name: SettingItems.wifi.rawValue, indexpath: IndexPath(row: 1, section: 0)),
        SearchData(name: SettingItems.bluetooth.rawValue, indexpath: IndexPath(row: 2, section: 0)),
        SearchData(name: SettingItems.mobileData.rawValue, indexpath: IndexPath(row: 3, section: 0)),
        SearchData(name: SettingItems.carrier.rawValue, indexpath: IndexPath(row: 4, section: 0)),
        SearchData(name: SettingItems.notifications.rawValue, indexpath: IndexPath(row: 0, section: 1)),
        SearchData(name: SettingItems.doNotDisturb.rawValue, indexpath: IndexPath(row: 1, section: 1)),
        SearchData(name: SettingItems.general.rawValue, indexpath: IndexPath(row: 0, section: 2)),
        SearchData(name: SettingItems.wallpaper.rawValue, indexpath: IndexPath(row: 1, section: 2)),
        SearchData(name: SettingItems.displayAndBrightness.rawValue, indexpath: IndexPath(row: 2, section: 2))
    ]
    
    private var isHeightForIndexpaths: [IndexPath : Bool] = [
        IndexPath(row: 0, section: 0): true,
        IndexPath(row: 1, section: 0): true,
        IndexPath(row: 2, section: 0): true,
        IndexPath(row: 3, section: 0): true,
        IndexPath(row: 4, section: 0): true,
        IndexPath(row: 0, section: 1): true,
        IndexPath(row: 1, section: 1): true,
        IndexPath(row: 0, section: 2): true,
        IndexPath(row: 1, section: 2): true,
        IndexPath(row: 2, section: 2): true,
    ]
    
    private var isHeightForSections: [Bool] = Array(repeating: true, count: 3)
    
    lazy private var filteredSearchArray: [SearchData] = {
        return searchArray
    }()
    
    @IBOutlet private weak var searchBar: UISearchBar!{
        didSet {
            searchBar.delegate = self
            searchBar.returnKeyType = .done
            searchBar.showsCancelButton = true
        }
    }
    @IBOutlet private weak var airplaneModeSwitch: UISwitch!
    @IBOutlet private weak var wifiNetworkNameLabel: UILabel!
    @IBOutlet private weak var bluetoothStatusLabel: UILabel!
    @IBOutlet private weak var carrierNetworkNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncWithCoreData()
    }
    
    @IBAction private func updateAirplaneModeStatus(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "airplane_mode_status")
    }
    
    func update() {
        syncWithCoreData()
    }
    
    
    private func syncWithCoreData() {
        if UserDefaults.standard.bool(forKey: "airplane_mode_status") {
            airplaneModeSwitch.setOn(true, animated: true)
        } else {
            airplaneModeSwitch.setOn(false, animated: true)
        }
        wifiNetworkNameLabel.text = UserDefaults.standard.string(forKey: "wifi_network_name") ?? ""
        if UserDefaults.standard.bool(forKey: "bluetooth_status") {
            bluetoothStatusLabel.text = "On"
        } else {
            bluetoothStatusLabel.text = "Off"
        }
        carrierNetworkNameLabel.text = UserDefaults.standard.string(forKey: "carrier_network_name") ?? ""
    }
    
    @IBAction func unwindToMasterViewController(_ sender: UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Identifiers.selectNetwork.rawValue:
            if let vc = segue.destination as? UINavigationController {
                if let nextVC = vc.children.first as? SelectNetworkViewController {
                    nextVC.networkType = networkType
                    nextVC.delegate = self
                }
            }
        case Identifiers.someText.rawValue:
            if let vc = segue.destination as? UINavigationController {
                if let nextVC = vc.children.first as? TextViewController {
                    nextVC.textType = textType
                }
            }
        case Identifiers.singleSwitch.rawValue:
            if let vc = segue.destination as? UINavigationController {
                if let nextVC = vc.children.first as? SingleSwitchViewController {
                    nextVC.singleSwitchType = singleSwitchType
                    nextVC.delegate = self
                }
            }
        default: break
        }
    }
}
//MARK: Search bar configuration
extension TableViewcontroller: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if isSearchBarEmpty() {
            isHeightForIndexpaths.forEach { isHeightForIndexpaths[$0.key] = true }
            isHeightForSections.enumerated().forEach { isHeightForSections[$0.offset] = true }
        } else {
            filteredSearchArray = searchArray.filter { $0.name.lowercased().contains(searchText.lowercased())}
            isHeightForIndexpaths.forEach { isHeightForIndexpaths[$0.key] = false }
            isHeightForSections.enumerated().forEach { isHeightForSections[$0.offset] = false }
            filteredSearchArray.forEach {
                isHeightForIndexpaths[$0.indexpath] = true
                switch $0.indexpath.section {
                case 0: isHeightForSections[0] = true
                case 1: isHeightForSections[1] = true
                case 2: isHeightForSections[2] = true
                default: break
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        isHeightForIndexpaths.forEach { isHeightForIndexpaths[$0.key] = true }
        isHeightForSections.enumerated().forEach { isHeightForSections[$0.offset] = true }
        tableView.reloadData()
    }
    
    private func isSearchBarEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
}
//MARK: split ViewController configuration
extension TableViewcontroller: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if traitCollection.horizontalSizeClass != .regular || traitCollection.verticalSizeClass == .regular {
            self.navigationController?.navigationBar.prefersLargeTitles = false
            return true
        }
        return false
    }
}
//MARK: row selection
extension TableViewcontroller {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let isHeightForSection = isHeightForSections[section]
        return isHeightForSection ? sectionHeight : 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let isHeightForRow = isHeightForIndexpaths[indexPath] {
            return isHeightForRow ? rowHeight : 0.0
        } else {
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let isCellVisible = isHeightForIndexpaths[indexPath]  {
            isCellVisible ? (cell.isHidden = false) : (cell.isHidden = true)
        }
    }
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath == IndexPath(row: 0, section: 0) {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: selectedSection0(at: indexPath.row)
        case 1: selectedSection1(at: indexPath.row)
        case 2: selectedSection2(at: indexPath.row)
        default: break
        }
    }
    
    private func selectedSection0(at row: Int) {
        switch row {
        case 2:
            singleSwitchType = .bluetooth
            performSegue(withIdentifier: Identifiers.singleSwitch.rawValue, sender: nil)
        case 1:
            networkType = .network
            performSegue(withIdentifier: Identifiers.selectNetwork.rawValue, sender: nil)
        case 4:
            networkType = .carrier
            performSegue(withIdentifier: Identifiers.selectNetwork.rawValue, sender: nil)
        default: break
        }
    }
    
    private func selectedSection1(at row: Int) {
        switch row {
        case 0:
            singleSwitchType = .notifications
            performSegue(withIdentifier: Identifiers.singleSwitch.rawValue, sender: nil)
        case 1:
            singleSwitchType = .doNotDisturb
            performSegue(withIdentifier: Identifiers.singleSwitch.rawValue, sender: nil)
        default: break
        }
    }
    
    private func selectedSection2(at row: Int) {
        switch row {
        case 0:
            textType = .general
            performSegue(withIdentifier: Identifiers.someText.rawValue, sender: nil)
        case 1:
            textType = .wallpaper
            performSegue(withIdentifier: Identifiers.someText.rawValue, sender: nil)
        default: break
        }
    }
}

enum SettingItems: String {
    case airplaneMode = "Airplane Mode"
    case wifi = "Wi-Fi"
    case bluetooth = "Bluetooth"
    case mobileData = "Mobile Data"
    case carrier = "Carrier"
    case notifications = "Notifications"
    case doNotDisturb = "Do not Disturb"
    case general = "General"
    case wallpaper = "Wallpaper"
    case displayAndBrightness = "Display & Brightness"
}

struct Settings {
    enum NetworkType: String {
        case network
        case carrier
    }
    
    enum SingleSwitchType {
        case bluetooth
        case notifications
        case doNotDisturb
    }
    
    enum TextType {
        case general
        case wallpaper
    }
}

enum Identifiers: String {
    case singleSwitch = "SingleSwitch"
    case someText = "SomeText"
    case selectNetwork = "SelectNetwork"
}

struct SearchData: Equatable {
    var name: String
    var indexpath: IndexPath
}
