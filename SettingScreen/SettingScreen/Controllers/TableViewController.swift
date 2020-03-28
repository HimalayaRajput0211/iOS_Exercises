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
    lazy private var filteredSearchArray: [SearchData] = {
        return searchArray
    }()
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var airplaneModeSwitch: UISwitch!
    @IBOutlet weak var wifiNetworkNameLabel: UILabel!
    @IBOutlet weak var bluetoothStatusLabel: UILabel! 
    @IBOutlet weak var carrierNetworkNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncWithCoreData()
    }
    
    @IBAction func updateAirplaneModeStatus(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "airplane_mode_status")
    }
    
    func update() {
        syncWithCoreData()
    }
    
    private func scrollToSearchedText() {
        if let indexPath = filteredSearchArray.first?.indexpath {
            let scrollPosition = UITableView.ScrollPosition.none
            tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
        }
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
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 40.0
        case 1: return 40.0
        case 2: return 40.0
        default: break
        }
        return 0.0
    }
    
    private var count = 0
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.isHidden = true
        }
        tableView.setNeedsDisplay()
//        print(filteredSearchArray.count)
//        if count < filteredSearchArray.count {
//        if filteredSearchArray[count].indexpath != indexPath {
//            cell.isHidden = true
//             print(indexPath)
//        }
//          count += 1
//        }
//        print(count)

    }
}
//MARK: Search bar configuration
extension TableViewcontroller: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredSearchArray = searchArray.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      //  scrollToSearchedText()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
//MARK: split ViewController configuration
extension TableViewcontroller: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if traitCollection.horizontalSizeClass != .regular || traitCollection.verticalSizeClass != .regular {
            self.navigationController?.navigationBar.prefersLargeTitles = false
            return true
        }
        self.navigationController?.navigationBar.prefersLargeTitles = true
        return false
    }
}
//MARK: row selection
extension TableViewcontroller {
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

struct SearchData {
    var name: String
    var indexpath: IndexPath
}
